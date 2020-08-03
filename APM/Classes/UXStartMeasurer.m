//
//  UXStartMeasurer.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/5/28.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXStartMeasurer.h"
#import "UXAPMReporter.h"

@implementation UXStartMeasurer

+ (void)load {
    [UXAPMReporter sharedReporter].appLaunchStartTime = [@([NSDate date].timeIntervalSince1970*1000) longLongValue];
    
    @autoreleasepool {
        id<NSObject> obs = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UXAPMReporter sharedReporter].appLaunchEndTime = [@([NSDate date].timeIntervalSince1970*1000) longLongValue];
            });
            
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] removeObserver:obs];
        });
    }
}

@end
