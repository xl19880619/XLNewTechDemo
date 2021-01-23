//
//  AppDelegate.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/5/29.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "AppDelegate.h"
//#import <UXAPM/UXAPMAgent.h>
#import "NavigationController.h"
#import "ViewController.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/mach.h>

@interface AppDelegate ()


@end

@implementation AppDelegate

+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *)btd_platform
{
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSString *)btd_hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *platform = [AppDelegate btd_platform];
    NSString *model = [AppDelegate btd_hwmodel];
    // Override point for customization after application launch.
    self.mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *vc = [[ViewController alloc] init];
    NavigationController *nv = [[NavigationController alloc] initWithRootViewController:vc];
    self.mainWindow.rootViewController = nv;
    [self.mainWindow makeKeyAndVisible];
    return YES;
}

@end
