//
//  UXANRMonitor.m
//  UXANRMonitor
//
//  Created by 谢雷 on 2019/1/10.
//  Copyright © 2019 Conan. All rights reserved.
//

#import "UXANRMonitor.h"

@interface UXANRMonitor () {
    
    dispatch_semaphore_t semaphore;
    CFRunLoopObserverRef runLoopObserver;
    CFRunLoopActivity activity;
    
    NSUInteger timeoutCount;
}

//@property (nonatomic) BOOL isStarting;

@property (copy, nonatomic) void (^ANROccuredCallback)(void);

@end

@implementation UXANRMonitor

+ (instancetype)shareInstance{
    static UXANRMonitor *_uxANRMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uxANRMonitor = [[UXANRMonitor alloc] init];
    });
    return _uxANRMonitor;
}

- (instancetype)init{
    if (self = [super init]) {
        //do something
    }
    return self;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    UXANRMonitor *moniotr = (__bridge UXANRMonitor*)info;

    // 记录状态值
    moniotr->activity = activity;

    // 发送信号
    dispatch_semaphore_t semaphore = moniotr->semaphore;
    dispatch_semaphore_signal(semaphore);
//    NSLog(@"2222222");
}

/*
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
 kCFRunLoopEntry = (1UL << 0), // 进入runloop的时候
 kCFRunLoopBeforeTimers = (1UL << 1),// 执行timer前
 kCFRunLoopBeforeSources = (1UL << 2), // 执行事件源前
 kCFRunLoopBeforeWaiting = (1UL << 5),//休眠前
 kCFRunLoopAfterWaiting = (1UL << 6),//休眠后
 kCFRunLoopExit = (1UL << 7),// 退出
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 */
- (void)registerObserver
{
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                              kCFRunLoopAllActivities,
                                              YES,
                                              0,
                                              &runLoopObserverCallBack,
                                              &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);

    // 创建信号
    semaphore = dispatch_semaphore_create(0);

    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            // 假定连续5次超时50ms认为卡顿(当然也包含了单次超时250ms)
            long semaphoreWait = dispatch_semaphore_wait(self->semaphore, dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC));
            if (semaphoreWait != 0) {
                if (!self->runLoopObserver) {
                    self->timeoutCount = 0;
                    self->semaphore = 0;
                    self->activity = 0;
                    return;
                }
                if (self->activity==kCFRunLoopBeforeSources || self->activity==kCFRunLoopAfterWaiting) {
                    if (++self->timeoutCount < 100) {
                        continue;
                    } else {
                    // 检测到卡顿，进行卡顿上报
                        NSLog(@"iOSANROccured");
                        if (self.ANROccuredCallback) {
                            self.ANROccuredCallback();
                        }
                    }
                }
            }
            self->timeoutCount = 0;
        }
    });
}

- (void)startMonitor{
    if (runLoopObserver) {
        return;
    }
    self->timeoutCount = 0;
    [self registerObserver];
}

- (void)startMonitorAfterANROccuredCallback:(void(^)(void))callback{
    self.ANROccuredCallback = callback;
    [self startMonitor];
}

- (void)stopMonitor{
    if (!runLoopObserver) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(runLoopObserver);
    runLoopObserver = NULL;
}

@end
