//
//  UXLocationManager.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/4/9.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXLocationManager : NSObject

+ (instancetype)sharedManager;

- (void)start;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
