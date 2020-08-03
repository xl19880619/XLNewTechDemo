//
//  UXLocationManager.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/4/9.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UXAPMTracker.h"

@interface UXLocationManager ()<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation UXLocationManager

+ (instancetype)sharedManager{
    static UXLocationManager *_locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [[UXLocationManager alloc] init];
    });
    return _locationManager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.latitude = 0;
        self.longitude = 0;
    }
    return self;
}

- (void)start{
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) && [CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
    } else {
//        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.delegate = self;
//        [self.locationManager startUpdatingLocation];

//        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"didChangeAuthorizationStatus");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location  = [locations lastObject];
    
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_didUpdateLocations",__FUNCTION__,__LINE__] type:UXAPMTrackerTypeCommon];
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_locationManager:didFailWithError:%@",__FUNCTION__,__LINE__,error] type:UXAPMTrackerTypeCommon];
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}

@end
