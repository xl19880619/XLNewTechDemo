//
//  UXRenderMonitorModel.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXRenderMonitorModel : NSObject

@property (copy, nonatomic) NSString *className;
@property (copy, nonatomic) NSString *uniqueID;

@property (copy, nonatomic) NSString *uploadTitle;

@property (nonatomic) long long loadViewStartTime;
@property (nonatomic) long long loadViewEndTime;

@property (copy, nonatomic) NSArray *loadViewDetailInfos;

@property (copy, nonatomic) NSArray *viewWillLayoutTimes;
@property (copy, nonatomic) NSArray *viewDidLayoutTimes;

@property (copy, nonatomic) NSArray *viewWillAppearTimes;
@property (copy, nonatomic) NSArray *viewDidAppearTimes;

/**
 判断页面加载是否完成，不继续统计加载中的方法时间
 */
@property (nonatomic) BOOL isViewDidAppear;

@property (nonatomic) BOOL viewWillDisappearCalled;

@property (nonatomic) BOOL viewDidDisappearCalled;

- (void)appendDetailInfoWithMethodName:(NSString *)methodName begin:(long long)begin end:(long long)end;
@end
