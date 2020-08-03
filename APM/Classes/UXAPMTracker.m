//
//  UXAPMTracker.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXAPMTracker.h"
#import "UXAPMConfig.h"

@interface UXAPMTracker ()

@property (strong, nonatomic) NSMutableArray *messages;

+ (instancetype)defaultTracker;

@end

@implementation UXAPMTracker

+ (instancetype)defaultTracker{
    static UXAPMTracker *_defaultTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTracker = [[UXAPMTracker alloc] init];
    });
    return _defaultTracker;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    if (self = [super init]) {
        //初始化基本信息
    }
    return self;
}

- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

+ (void)trackMessage:(NSString *)message{
    [self trackMessage:message type:UXAPMTrackerTypeCommon];
}

+ (void)trackMessage:(NSString *)message type:(UXAPMTrackerType )type{
    if ([UXAPMConfig sharedConfig].logEnable) {
        NSLog(@"%@",message);
    }
}


@end
