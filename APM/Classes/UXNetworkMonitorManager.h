//
//  NetworkMonitorManager.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/1/31.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UXNetworkMonitorModel;

@interface UXNetworkMonitorManager : NSObject

+ (instancetype)sharedManager;

@end

@interface NSObject (Monitor)

@property (strong, nonatomic) UXNetworkMonitorModel *networkMonitor;

@end
