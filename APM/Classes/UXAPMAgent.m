//
//  UXAPMAgent.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/26.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXAPMAgent.h"
#import "UXAPMReporter.h"
#import "UXAPMConfig.h"
#import "UXAPMTracker.h"
#import "UXStartMeasurer.h"
#import "CoreInfoModel.h"

@implementation UXAPMAgent

+ (void)startWithAppId:(NSString *)appId{
    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_start",__FUNCTION__,__LINE__]];
    [UXAPMReporter sharedReporter].appId = appId;
    [[UXAPMConfig sharedConfig] startAll];
    
    CoreInfoModel *model = [[CoreInfoModel alloc] init];
    model.title = @"";
    NSLog(@"model %@",model);
}

+ (void)setDebugMode:(BOOL)debugMode{
    [UXAPMConfig sharedConfig].debugMode = debugMode;
}

+ (void)enableLog{
    [UXAPMConfig sharedConfig].logEnable = YES;
}

+ (NSString *)sdkVersion{
    return [UXAPMConfig APMSDKVersion];
}

+ (void)setIgnoredHosts:(NSSet<NSString *> *)ignoredMonitorHosts{
    [UXAPMConfig sharedConfig].ignoredMonitorHosts = ignoredMonitorHosts;
}

+ (void)setMaxMonitorCount:(NSUInteger)maxCount{
    if (maxCount > 0) {
        [UXAPMConfig sharedConfig].maxCountOfData = maxCount;
    }
}

+ (void)appStartDidFinished{
    [UXAPMReporter sharedReporter].appLaunchEndTime = [@([NSDate date].timeIntervalSince1970*1000) longLongValue];
}
@end
