//
//  AppDelegate.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/5/29.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <UXAPM/UXAPMAgent.h>
//#import "BaiduPanoramaView.h"

@interface AppDelegate ()

//@property (nonatomic, strong) BaiduPanoramaView *view;

@end

@implementation AppDelegate

- (CGSize)getStringRect:(NSAttributedString *)aString size:(CGSize )sizes
{
    CGRect strSize = [aString boundingRectWithSize:CGSizeMake(sizes.width, sizes.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return  CGSizeMake(strSize.size.width, strSize.size.height);
}


- (void)check {
    NSArray *array1 = @[@3, @5, @7, @2, @1, @4];
    NSArray *array2 = @[@3, @7, @6, @1, @5, @9, @8];
    NSMutableArray *result = [NSMutableArray array];
    for (NSNumber *num1 in array1) {
        for (NSNumber *num2 in array2) {
            if (num1.integerValue == num2.integerValue) {
                [result addObject:num1];
            }
        }
    }
    NSMutableArray *newResult1 = result.mutableCopy;
    for (NSNumber *number in result) {
        for (NSNumber *num1 in array1) {
            if (num1.integerValue == number.integerValue) {
                NSUInteger index = [result indexOfObject:number];
                if (index > 1) {
                    if ([array1 indexOfObject:num1] < [array1 indexOfObject:[result objectAtIndex:index - 1]]) {
                        [newResult1 removeObject:num1];
                    }
                }
            }
        }
    }
    
    NSMutableArray *newReulst2 = result.mutableCopy;
    for (NSNumber *number in result) {
        for (NSNumber *num2 in array2) {
            if (num2.integerValue == number.integerValue) {
                NSUInteger index = [result indexOfObject:number];
                if (index > 1) {
                    if ([array2 indexOfObject:num2] < [array2 indexOfObject:[result objectAtIndex:index - 1]]) {
                        [newReulst2 removeObject:num2];
                    }
                }
            }
        }
    }
    
    NSLog(@"result %@ n1:%@ n2:%@",result,newResult1,newReulst2);
    //[3, 5, 7, 1]
    //[3, 7, 1]
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [IQKeyboardManager sharedManager].enable = NO;
    [self check];
    [UXAPMAgent startWithAppId:@"111"];
//    self.view
    CGSize siz = [self getStringRect:nil size:CGSizeMake(CGFLOAT_MAX, 10)];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
