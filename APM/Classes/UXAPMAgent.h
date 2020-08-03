//
//  UXAPMAgent.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/26.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXAPMAgent : NSObject

/**
 启动APM功能，并指定当前应用id
 具体id查看 http://oa.youxinpai.com/wiki/index.php/APP_SOURCE%E5%90%84%E7%AB%AF%E9%85%8D%E7%BD%AE%E4%BD%BF%E7%94%A8
 @param appId source_id，字符串类型
 */
+ (void)startWithAppId:(NSString *)appId;

/**
 设置调试模式  (调试模式：有大量Log输出，便于追踪)

 @param debugMode 默认正式服务 True：调试模式，上报测试服务 False：线上模式，上报正式服务
 */
+ (void)setDebugMode:(BOOL)debugMode;

/**
 打开Log输出，默认关闭
 */
+ (void)enableLog;

/**
 返回当前APM SDK版本 (eg:1.0.0)

 @return 版本，字符串类型
 */
+ (NSString *)sdkVersion;

/**
 过滤不需要统计api的host (eg:api.xin.com)

 @param ignoredMonitorHosts 域名，字符串类型
 */
+ (void)setIgnoredHosts:(NSSet<NSString *> *)ignoredMonitorHosts;

/**
 设置统计最大上传个数，达到个数即上报

 @param maxCount NSUInteger类型
 */
+ (void)setMaxMonitorCount:(NSUInteger)maxCount;

/**
 应用启动完成，建议在首页加载完数据后调用。
 不调用，默认上传 UIApplicationDidFinishLaunchingNotification 通知截止时间
 */
+ (void)appStartDidFinished;

@end
