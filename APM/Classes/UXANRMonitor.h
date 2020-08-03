//
//  UXANRMonitor.h
//  UXANRMonitor
//
//  Created by 谢雷 on 2019/1/10.
//  Copyright © 2019 Conan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXANRMonitor : NSObject

+ (instancetype)shareInstance;

- (void)startMonitor;

- (void)startMonitorAfterANROccuredCallback:(void(^)(void))callback;

- (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
