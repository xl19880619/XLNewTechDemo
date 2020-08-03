//
//  UXAPMConfig.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXAPMConfig.h"
#import "sys/utsname.h"

NSString * const kUXAPMCeShiIgnoredMonitorHost =  @"api.ceshi.xin.com";

@interface UXAPMConfig ()

/**
 APM功能是否可用
 */
@property (nonatomic) BOOL isEnabled;
@end

@implementation UXAPMConfig

@synthesize ignoredMonitorHosts = _ignoredMonitorHosts;

+ (instancetype)sharedConfig{
    static UXAPMConfig *_apmConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apmConfig = [[UXAPMConfig alloc] init];
    });
    return _apmConfig;
}

- (instancetype)init{
    if (self = [super init]) {
        self.maxCountOfData = 50;
        self.isEnabled = NO;
        self.debugMode = NO;
        self.logEnable = NO;
        self.ignoredMonitorHosts = [NSSet setWithArray:@[kUXAPMCeShiIgnoredMonitorHost]];
    }
    return self;
}

+ (NSString *)APMSDKVersion{
    return @"0.9.0";
}

+ (NSString *)appVersion{
    //CFBundleVersion
    //CFBundleShortVersionString
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return bundleVersion;
}

+ (NSString *)iosSysVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)deviceIdentifier{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *)deviceType{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSDictionary *deviceDict = @{
                                 //iPhone
                                 @"iPhone1,1" : @"iPhone",
                                 @"iPhone1,2" : @"iPhone 3G",
                                 @"iPhone2,1" : @"iPhone 3GS",
                                 @"iPhone3,1" : @"iPhone 4",
                                 @"iPhone3,2" : @"iPhone 4",
                                 @"iPhone3,3" : @"iPhone 4",
                                 @"iPhone4,1" : @"iPhone 4S",
                                 @"iPhone5,1" : @"iPhone 5",
                                 @"iPhone5,2" : @"iPhone 5",
                                 @"iPhone5,3" : @"iPhone 5C",
                                 @"iPhone5,4" : @"iPhone 5C",
                                 @"iPhone6,1" : @"iPhone 5S",
                                 @"iPhone6,2" : @"iPhone 5S",
                                 @"iPhone7,1" : @"iPhone 6 Plus",
                                 @"iPhone7,2" : @"iPhone 6",
                                 @"iPhone8,1" : @"iPhone 6S",
                                 @"iPhone8,2" : @"iPhone 6S Plus",
                                 @"iPhone8,4" : @"iPhone SE",
                                 @"iPhone9,1" : @"iPhone 7",
                                 @"iPhone9,2" : @"iPhone 7 Plus",
                                 @"iPhone9,3" : @"iPhone 7",
                                 @"iPhone9,4" : @"iPhone 7 Plus",
                                 @"iPhone10,1" : @"iPhone 8",
                                 @"iPhone10,2" : @"iPhone 8 Plus",
                                 @"iPhone10,3" : @"iPhone X",
                                 @"iPhone10,4" : @"iPhone 8",
                                 @"iPhone10,5" : @"iPhone 8 Plus",
                                 @"iPhone10,6" : @"iPhone X",
                                 //iPad
                                 @"iPad1,1" : @"iPad",
                                 @"iPad1,2" : @"iPad",
                                 @"iPad2,1" : @"iPad 2",
                                 @"iPad2,2" : @"iPad 2",
                                 @"iPad2,3" : @"iPad 2",
                                 @"iPad2,4" : @"iPad 2",
                                 @"iPad2,5" : @"iPad Mini",
                                 @"iPad2,6" : @"iPad Mini",
                                 @"iPad2,7" : @"iPad Mini",
                                 @"iPad3,1" : @"iPad 3",
                                 @"iPad3,2" : @"iPad 3",
                                 @"iPad3,3" : @"iPad 3",
                                 @"iPad3,4" : @"iPad 4",
                                 @"iPad3,5" : @"iPad 4",
                                 @"iPad3,6" : @"iPad 4",
                                 @"iPad4,1" : @"iPad Air",
                                 @"iPad4,2" : @"iPad Air",
                                 @"iPad4,3" : @"iPad Air",
                                 @"iPad4,4" : @"iPad Mini 2",
                                 @"iPad4,5" : @"iPad Mini 2",
                                 @"iPad4,6" : @"iPad Mini 2",
                                 @"iPad4,7" : @"iPad Mini 3",
                                 @"iPad4,8" : @"iPad Mini 3",
                                 @"iPad4,9" : @"iPad Mini 3",
                                 @"iPad5,1" : @"iPad Mini 4",
                                 @"iPad5,2" : @"iPad Mini 4",
                                 @"iPad5,3" : @"iPad Air 2",
                                 @"iPad5,4" : @"iPad Air 2",
                                 @"iPad6,3" : @"iPad Pro",//9.7
                                 @"iPad6,4" : @"iPad Pro",//9.7
                                 @"iPad6,7" : @"iPad Pro",//12.9
                                 @"iPad6,8" : @"iPad Pro",//12.9
                                 @"iPad6,11" : @"iPad 5",
                                 @"iPad6,12" : @"iPad 5",
                                 @"iPad7,1" : @"iPad Pro 2",//12.9
                                 @"iPad7,2" : @"iPad Pro 2",//12.9
                                 @"iPad7,3" : @"iPad Pro 2",//10.5
                                 @"iPad7,4" : @"iPad Pro 2",//10.5
                                 //iPod Touch
                                 @"iPod1,1" : @"iPod Touch",
                                 @"iPod2,1" : @"iPod Touch",
                                 @"iPod3,1" : @"iPod Touch",
                                 @"iPod4,1" : @"iPod Touch",
                                 @"iPod5,1" : @"iPod Touch",
                                 @"iPod7,1" : @"iPod Touch",
                                 //Simulator
                                 @"i386" : @"Simulator",
                                 @"x86_64" : @"Simulator"
                                 };
    
    if ([deviceDict objectForKey:deviceString] != nil) {
        return deviceDict[deviceString];
    }
    
    return @"Unknown";
}

- (void)setIgnoredMonitorHosts:(NSSet<NSString *> *)ignoredMonitorHosts{
    _ignoredMonitorHosts = [[NSSet setWithSet:ignoredMonitorHosts] setByAddingObjectsFromArray:@[kUXAPMCeShiIgnoredMonitorHost]];
}

- (NSSet<NSString *> *)ignoredMonitorHosts{
    if (!_ignoredMonitorHosts) {
        _ignoredMonitorHosts = [NSSet setWithArray:@[kUXAPMCeShiIgnoredMonitorHost]];
    }
    return _ignoredMonitorHosts;
}

- (void)startAll{
    self.isEnabled = YES;
}

- (void)disableAll{
    self.isEnabled = NO;
}

- (BOOL)sdk_enabled{
    return self.isEnabled;
}

@end
