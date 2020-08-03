//
//  UXAPMReporter.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UXNetworkMonitorModel,UXRenderMonitorModel;

typedef NS_ENUM(NSUInteger,UXAPMRenderType) {
    UXAPMRenderTypeViewDidLoad,
    UXAPMRenderTypeViewWillAppear,
    UXAPMRenderTypeViewDidAppear,
    UXAPMRenderTypeViewWillLayout,
    UXAPMRenderTypeViewDidLayout
};

/**
 上报类，网络数据、页面数据汇总，检查，并上报
 */
@interface UXAPMReporter : NSObject

+ (instancetype)sharedReporter;

/**
 添加网络统计Model

 @param networkMonitor UXNetworkMonitorModel 类型
 */
- (void)addNetworkMonitor:(UXNetworkMonitorModel *)networkMonitor;

/**
 添加UI统计Model

 @param model UXRenderMonitorModel 类型
 */
- (void)addRenderModel:(UXRenderMonitorModel *)model;

- (UXRenderMonitorModel *)modelWithUniqueID:(NSString *)uniqueID;


/**
 检查是否符合上报条件，符合及上传
 */
- (void)checkIfAchieveMaxCountLimit;

/**
 appId 由UXAPMAgent startWithAppId获取，如果未赋值，则不会上报
 */
@property (copy, nonatomic) NSString *appId;

/**
 应用启动开始计时，单位ms
 */
@property (nonatomic) long long appLaunchStartTime;

/**
 应用启动结束计时，单位ms
 */
@property (nonatomic) long long appLaunchEndTime;

@property (weak, nonatomic) UXRenderMonitorModel *currendModel;

@end
