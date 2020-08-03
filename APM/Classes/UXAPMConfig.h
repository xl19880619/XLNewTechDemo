//
//  UXAPMConfig.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 UXAPM全局配置
 启用 OR 停用 某些功能
 过滤某些不需要统计的功能
 */
@interface UXAPMConfig : NSObject

+ (instancetype)sharedConfig;

@property (nonatomic) NSUInteger maxCountOfData;

@property (strong, nonatomic) NSSet<NSString *> *ignoredMonitorHosts;

@property (nonatomic) BOOL debugMode;

@property (nonatomic) BOOL logEnable;

/**
 启用APM
 */
- (void)startAll;
/**
 停用全部APM功能
 */
- (void)disableAll;

/**
 查看SDK是否可用

 @return True：可用 False：不可用
 */
- (BOOL)sdk_enabled;

/**
 APM sdk 版本

 @return 字符串类型 eg：1.0.0
 */
+ (NSString *)APMSDKVersion;

/**
 APP 版本

 @return 字符串类型 eg：1.0.0
 */
+ (NSString *)appVersion;

/**
 当前系统版本

 @return 字符串类型 eg：11.1.1
 */
+ (NSString *)iosSysVersion;

/**
 设备唯一ID

 @return 字符串类型
 */
+ (NSString *)deviceIdentifier;

/**
 设备类型

 @return 设备类型字符串 eg：iphone X
 */
+ (NSString *)deviceType;

@end
