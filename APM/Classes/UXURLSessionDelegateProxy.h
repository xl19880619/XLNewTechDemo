//
//  URLSessionDelegateProxy.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/1/31.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXURLSessionDelegateProxy : NSProxy<NSURLSessionDelegate>

- (instancetype)initWithTarget:(id)target;

@end
