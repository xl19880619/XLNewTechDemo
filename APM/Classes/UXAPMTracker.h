//
//  UXAPMTracker.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 一个追踪系统
 DEBUG模式兼具Log功能
 有必要时可上传
 */

typedef NS_ENUM(NSUInteger,UXAPMTrackerType) {
    UXAPMTrackerTypeCommon,
    UXAPMTrackerTypeError,
    UXAPMTrackerTypeCrash,
    UXAPMTrackerTypeNetwork,
    UXAPMTrackerTypeUI
};

@interface UXAPMTracker : NSObject

+ (void)trackMessage:(NSString *)message;
+ (void)trackMessage:(NSString *)message type:(UXAPMTrackerType )type;

@end
