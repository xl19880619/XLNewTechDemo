//
//  RenderMonitorManager.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/2/2.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UXRenderMonitorManager : NSObject

+ (instancetype)sharedManager;

@end

@interface UIViewController (Monitor)

@property (copy, nonatomic) NSString *uniqueID;

- (void)generateUniqueID;

@end

