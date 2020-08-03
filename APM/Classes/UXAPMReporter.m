//
//  UXAPMReporter.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXAPMReporter.h"
#import "UXAPMConfig.h"
#import "UXNetworkMonitorModel.h"
#import "UXRenderMonitorModel.h"
#import "UXReachability.h"
#import "UXAPMTools.h"
#import "UXAPMTracker.h"
#import "UXLocationManager.h"

static dispatch_queue_t ux_apm_reporter_creation_queue() {
    static dispatch_queue_t ux_apm_reporter_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ux_apm_reporter_creation_queue = dispatch_queue_create("com.uxin.apm.reporter", DISPATCH_QUEUE_SERIAL);
    });
    return ux_apm_reporter_creation_queue;
}

@interface UXAPMReporter ()<NSURLSessionDelegate>

@property (strong, nonatomic) NSMutableArray *networkDataArray;

@property (strong, nonatomic) NSMutableDictionary *renderDataDict;

@property (strong, nonatomic) NSMutableArray *temporaryRenderArray;

@property (strong, nonatomic) UXReachability *reachability;

@property (strong, nonatomic) NSURLSession *session;

@property (nonatomic) BOOL isUploadingData;

@end

@interface UXQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

NSArray * UXQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:UXQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:UXQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:UXQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[UXQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

NSArray * UXQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return UXQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSString * UXQueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (UXQueryStringPair *pair in UXQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

@implementation UXAPMReporter

+ (instancetype)sharedReporter{
    static UXAPMReporter *_apmReporter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apmReporter = [[UXAPMReporter alloc] init];
    });
    return _apmReporter;
}

- (void)dealloc{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    if (self = [super init]) {
        self.renderDataDict = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        self.reachability = [UXReachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
        
        self.isUploadingData = NO;
        
        [[UXLocationManager sharedManager] start];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 3.获得会话对象
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

    }
    return self;
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)aNotifiaction{
    
    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_applicationDidReceiveMemoryWarning",__FUNCTION__,__LINE__]];
}

- (NSMutableArray *)networkDataArray{
    if (!_networkDataArray) {
        _networkDataArray = [NSMutableArray array];
    }
    return _networkDataArray;
}

- (NSMutableArray *)temporaryRenderArray{
    if (!_temporaryRenderArray) {
        _temporaryRenderArray = [NSMutableArray array];
    }
    return _temporaryRenderArray;
}

- (void)addNetworkMonitor:(UXNetworkMonitorModel *)networkMonitor{
    if ([[UXAPMConfig sharedConfig].ignoredMonitorHosts containsObject:networkMonitor.host]) {
        return ;
    }
    dispatch_async(ux_apm_reporter_creation_queue(), ^{
        networkMonitor.networkType = self.reachability.currentReachabilityString;
        [self.networkDataArray addObject:networkMonitor];
        
        [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_addNetworkMonitor_duration:%f",__FUNCTION__,__LINE__,networkMonitor.responseEndTime-networkMonitor.requestCreateTime]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkIfAchieveMaxCountLimit];
        });
    });
}

- (void)addRenderModel:(UXRenderMonitorModel *)model{
    if (![self.renderDataDict objectForKey:model.uniqueID]) {
        [self.renderDataDict setObject:model forKey:model.uniqueID];
        self.currendModel = model;
    }
}

- (UXRenderMonitorModel *)modelWithUniqueID:(NSString *)uniqueID{
    if ([self.renderDataDict objectForKey:uniqueID]) {
        return [self.renderDataDict objectForKey:uniqueID];
    }
    return nil;
}

- (void)checkIfAchieveMaxCountLimit{
    NSUInteger totalCount = self.networkDataArray.count + self.renderDataDict.count*2;
    if (totalCount > [UXAPMConfig sharedConfig].maxCountOfData) {
        if (self.isUploadingData) {
            return;
        }
        self.isUploadingData = YES;
        [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_arrived,ready to upload",__FUNCTION__,__LINE__]];
        NSArray *networkDataArray = self.networkDataArray.copy;
        NSMutableArray *renderDataArray = [NSMutableArray array];
        for (UXRenderMonitorModel *model in self.renderDataDict.allValues) {
            if (!model.loadViewStartTime || !model.loadViewEndTime) {
                if ([self.temporaryRenderArray containsObject:model]) {
                    [self.temporaryRenderArray removeObject:model];
                } else {
                    [self.temporaryRenderArray addObject:model];
                }
            }else {
                if ([self.temporaryRenderArray containsObject:model]) {
                    [self.temporaryRenderArray removeObject:model];
                }
                [renderDataArray addObject:model];
            }
        }
        [self.renderDataDict removeAllObjects];
        if (self.temporaryRenderArray.count) {
            for (UXRenderMonitorModel *model in self.temporaryRenderArray) {
                [self.renderDataDict setObject:model forKey:model.uniqueID];
            }
        }
        dispatch_async(ux_apm_reporter_creation_queue(), ^{
            [self.networkDataArray removeAllObjects];
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            if (self.appId) {
                parameters[@"app_source"] = self.appId;
            }
            parameters[@"cid"] = [UXAPMConfig deviceIdentifier];
            parameters[@"appver"] = [UXAPMConfig appVersion];
            parameters[@"sdkver"] = [UXAPMConfig APMSDKVersion];
            parameters[@"os"] = @"ios";
            parameters[@"osver"] = [UXAPMConfig iosSysVersion];
            parameters[@"device_name"] = [UXAPMConfig deviceType];
            if ([UXLocationManager sharedManager].latitude && [UXLocationManager sharedManager].longitude) {
                parameters[@"latitude"] = @([UXLocationManager sharedManager].latitude);
                parameters[@"longitude"] = @([UXLocationManager sharedManager].longitude);
            }
            
            if (self.appLaunchStartTime > 0 && self.appLaunchEndTime > 0 && self.appLaunchEndTime > self.appLaunchStartTime) {
                NSMutableDictionary *launchDicts = [NSMutableDictionary dictionary];
                launchDicts[@"ts1"] = @(self.appLaunchStartTime);
                launchDicts[@"ts2"] = @(self.appLaunchEndTime);
                NSString *jsonString = [UXAPMTools convertJsonToString:@[launchDicts]];
                NSString *string = [UXAPMTools removeSpecialCharactors:jsonString];
                parameters[@"start_app_monitor"] = string;
                
                self.appLaunchEndTime = 0;
            }
            
            NSString *jsonNetString = [self jsonStringWithNetData:networkDataArray];
            if (jsonNetString.length) {
                parameters[@"net_work_monitor"] = jsonNetString;
            }
            
            if (renderDataArray.count) {
                NSMutableArray *lifeDicts = [NSMutableArray array];
                NSMutableArray *layoutDicts = [NSMutableArray array];
                for (UXRenderMonitorModel *model in renderDataArray) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    if (model.className.length) {
                        if (model.loadViewStartTime && model.loadViewEndTime) {
                            dic[@"name"] = model.uploadTitle;
                            dic[@"ts1"] = @(model.loadViewStartTime);
                            dic[@"ts2"] = @(model.loadViewEndTime);
                            if (model.loadViewDetailInfos.count) {
                                dic[@"item_time"] = model.loadViewDetailInfos;
                            }
                            [lifeDicts addObject:dic.copy];
                        }
                        if (model.viewWillAppearTimes.count && model.viewDidAppearTimes.count){
                            [dic removeAllObjects];
                            dic[@"name"] = model.uploadTitle;
                            dic[@"ts1"] = model.viewWillAppearTimes;
                            dic[@"ts2"] = model.viewDidAppearTimes;
                            [layoutDicts addObject:dic];
                        }
                    }
                }
                
                if (lifeDicts.count) {
                    NSString *jsonString = [UXAPMTools convertJsonToString:lifeDicts];
                    NSString *string = [UXAPMTools removeSpecialCharactors:jsonString];
                    if (string.length) {
                        parameters[@"page_load_monitor"] = string;
                    }
                }
                if (layoutDicts.count) {
                    NSString *jsonString = [UXAPMTools convertJsonToString:layoutDicts];
                    NSString *string = [UXAPMTools removeSpecialCharactors:jsonString];
                    if (string.length) {
                        parameters[@"page_render_monitor"] = string;
                    }
                }
            }
//            NSString *apiKey = [UXAPMTools apiKeyWithParameters:parameters];
//            parameters[@"_apikey"] = apiKey;
            [self uploadFinalDatas:parameters.copy];
        });
        
    }
}

- (NSString *)jsonStringWithNetData:(NSArray *)networkDataArray{
    NSMutableArray *netDicts = [NSMutableArray array];
    if (networkDataArray.count) {
        for (UXNetworkMonitorModel *model in networkDataArray) {
            //不需要时间强制判断，都全部上报给后端，统计次数
//            if (model.requestCreateTime && model.responseEndTime && model.domainLookupStartTime && model.domainLookupEndTime && model.connectStartTime && model.connectEndTime) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"type"] = model.networkType;
            dic[@"code"] = @(model.statusCode);
            //如果是图片，不需要apiPath，path不唯一
            if ([model.apiPath hasSuffix:@".jpg"] || [model.apiPath hasSuffix:@".jpg"] || [model.apiPath hasSuffix:@".png"] || [model.apiPath hasSuffix:@".jpeg"] || [model.apiPath hasSuffix:@".webp"] || [model.apiPath hasSuffix:@".js"]) {
                dic[@"apiurl"] = [NSString stringWithFormat:@"%@",model.host];
            } else {
                dic[@"apiurl"] = [NSString stringWithFormat:@"%@%@",model.host,model.apiPath];
            }
            //把时间转成毫秒
            dic[@"ts1"] = @(@(model.requestCreateTime*1000).longLongValue);
            dic[@"ts2"] = @(@(model.domainLookupStartTime*1000).longLongValue);
            dic[@"ts3"] = @(@(model.domainLookupEndTime*1000).longLongValue);
            dic[@"ts4"] = @(@(model.connectStartTime*1000).longLongValue);
            dic[@"ts5"] = @(@(model.connectEndTime*1000).longLongValue);
            dic[@"ts6"] = @(@(model.requestStartTime*1000).longLongValue);
            dic[@"ts7"] = @(@(model.requestEndTime*1000).longLongValue);
            dic[@"ts8"] = @(@(model.responseStartTime*1000).longLongValue);
            dic[@"ts9"] = @(@(model.responseEndTime*1000).longLongValue);

            [netDicts addObject:dic.copy];
//            }
        }
    }
    if (netDicts.count) {
        NSString *jsonString = [UXAPMTools convertJsonToString:netDicts];
        return [UXAPMTools removeSpecialCharactors:jsonString];
    }
    return nil;
}

- (void)uploadFinalDatas:(NSDictionary *)parameters{
    
    
    //1.创建一个网络路径
    NSString *domain = @"http://ab.xin.com";
    if ([UXAPMConfig sharedConfig].debugMode) {
        domain = @"https://ab.test.xin.com";
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/apm.gif",domain]];
    // 2.创建一个网络请求，分别设置请求方法、请求参数
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *args = UXQueryStringFromParameters(parameters);
    request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
    
    // 4.根据会话对象，创建一个Task任务
    __weak __typeof(&*self)weakSelf = self;
    
    NSURLSessionDataTask *sessionDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        /*
         对从服务器获取到的数据data进行相应的处理.
         {
         code = 1;
         data =     (
         );
         message = "\U64cd\U4f5c\U6210\U529f"; //操作成功
         }
         */
        

        NSString *log = [NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_get_response_from_server",__FUNCTION__,__LINE__];
        [UXAPMTracker trackMessage:log];
        /**
         修复崩溃问题，data可能为空
         */
        //启用打点接口后，code 403，无返回
//        if (error) {
//            NSString *log = [NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_get_response_from_server_error:%@",__FUNCTION__,__LINE__,error];
//            [UXAPMTracker trackMessage:log];
//        } else if (data.length) {
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
//            NSString *log = [NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_get_response_from_server:%@",__FUNCTION__,__LINE__,[UXAPMTools convertJsonToString:dict]];
//            [UXAPMTracker trackMessage:log];
//        }

        weakSelf.isUploadingData = NO;
    }];
    //5.最后一步，执行任务，(resume也是继续执行)。
    [sessionDataTask resume];
}

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks {
    if (cancelPendingTasks) {
        [self.session invalidateAndCancel];
    } else {
        [self.session finishTasksAndInvalidate];
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"ab.test.xin.com"] || [challenge.protectionSpace.host isEqualToString:@"ab.xin.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end

/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
NSString * UXPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

@implementation UXQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return UXPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", UXPercentEscapedStringFromString([self.field description]), UXPercentEscapedStringFromString([self.value description])];
    }
}

@end
