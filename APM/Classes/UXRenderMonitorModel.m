//
//  UXRenderMonitorModel.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXRenderMonitorModel.h"

@implementation UXRenderMonitorModel

- (NSString *)description{
    return [NSString stringWithFormat:@"UXRenderMonitorModel:%@_%@_loadViewDuration:%lld_detail:%@",self.className,self.uniqueID,self.loadViewEndTime-self.loadViewStartTime,self.loadViewDetailInfos];
}

- (void)appendDetailInfoWithMethodName:(NSString *)methodName begin:(long long)begin end:(long long)end{
    self.loadViewDetailInfos = [[NSArray arrayWithArray:self.loadViewDetailInfos] arrayByAddingObject:@{@"method_name":methodName,@"ts1":@(begin),@"ts2":@(end)}];
}

@end
