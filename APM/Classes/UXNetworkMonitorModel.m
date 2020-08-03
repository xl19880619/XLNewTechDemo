//
//  NetworkMonitorModel.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/2/2.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXNetworkMonitorModel.h"
#import "UXNetworkMonitorManager.h"
#import "UXAPMReporter.h"

@implementation UXNetworkMonitorModel

- (instancetype)init{
    if (self = [super init]) {
        self.requestCreateTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (void)requestFinished {
    self.responseEndTime = [[NSDate date] timeIntervalSince1970];
    [[UXAPMReporter sharedReporter] addNetworkMonitor:self];
}

- (void)collectBasicInfo:(NSURLSessionTask *)task response:(NSURLResponse *)response error:(NSError *)error{
    if (task) {
        self.host = task.originalRequest.URL.host;
        self.apiPath = task.originalRequest.URL.path;
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            task.networkMonitor.statusCode = [(NSHTTPURLResponse *)task.response statusCode];
        }
    } else if (response) {
        self.host = response.URL.host;
        self.apiPath = response.URL.path;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            task.networkMonitor.statusCode = [(NSHTTPURLResponse *)response statusCode];
        }
    }
    task.networkMonitor.errorCode = error ? error.code : 0;
    [task.networkMonitor requestFinished];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"UXAPM:__api:%@ \n NETYPE:%@ \n start:%f__end:%f \n DNSStart:%f__DNSEnd:%f \n ConnectStart:%f__ConnectEnd:%f",self.apiPath,self.networkType,self.requestCreateTime,self.responseEndTime,self.domainLookupStartTime,self.domainLookupEndTime,self.connectStartTime,self.connectEndTime];
}

@end
