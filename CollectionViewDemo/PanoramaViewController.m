//
//  PanoramaViewController.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/7/13.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "PanoramaViewController.h"
#import "CoreInfoViewController.h"
#import <Masonry/Masonry.h>

NSString *const kBaiduMapAKString = @"h32BfIVTwddG8P68o2gGoCHL";

@interface PanoramaViewController ()
//<BMKGeneralDelegate,BaiduPanoramaViewDelegate>

@property (nonatomic, strong) UIView *headerBGView;

//@property (nonatomic, weak) BaiduPanoramaView *panoramaView;
//
//@property (nonatomic, strong) BMKMapManager *mapManager;

@property (nonatomic, strong) UIView *bubbleView;

@end

@implementation PanoramaViewController
/**
 "gaode_lng": "84.84804887",
 "gaode_lat": "45.60301341",
 */

- (instancetype)init {
    if (self = [super init]) {
//        self.mapManager = [[BMKMapManager alloc] init];
//        BOOL ret = [self.mapManager start:kBaiduMapAKString generalDelegate:self];
//        if (!ret) {
//            NSLog(@"start fail");
//        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.view.backgroundColor = [UIColor blueColor];
//    BaiduPanoramaView *panoramaView = [[BaiduPanoramaView alloc] initWithFrame:self.view.bounds key:kBaiduMapAKString];
//    panoramaView.delegate = self;
//    [self.view addSubview:panoramaView];
//    self.panoramaView = panoramaView;
//    [self.panoramaView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];
//    [self.panoramaView setPanoramaWithLon:84.84804887 lat:45.60301341];
    
    NSString *text = @"This is Text";
    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bubbleView];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blueColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text = text;
    [label sizeToFit];

    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, label.frame.size.width + 20, label.frame.size.height + 20) cornerRadius:4];
    {
        UIBezierPath *recPath = [UIBezierPath bezierPath];
        [recPath moveToPoint:CGPointMake((label.frame.size.width + 20)/2 - 5, (label.frame.size.height + 20))];
        [recPath addLineToPoint:CGPointMake((label.frame.size.width + 20)/2, (label.frame.size.height + 20) + 5)];
        [recPath addLineToPoint:CGPointMake((label.frame.size.width + 20)/2 + 5, (label.frame.size.height + 20))];
        [recPath closePath];
        [path appendPath:recPath];
    }
        
        
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.path = path.CGPath;
    [self.bubbleView.layer addSublayer:layer];
    
    [self.bubbleView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_map_center_icon"]];
    [self.bubbleView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bubbleView);
        make.bottom.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(label.frame.size.width + 20);
        make.height.mas_equalTo(label.frame.size.height + 20 + 5 + 20);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
    NSLog(@"onGetNetworkState:%d",iError);
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError {
    NSLog(@"onGetPermissionState:%d",iError);
}

#pragma mark - 全景回掉
/**
 * @abstract 全景图将要加载
 * @param panoramaView 当前全景视图
 */
//- (void)panoramaWillLoad:(BaiduPanoramaView *)panoramaView {
//
//}

/**
 * @abstract 全景图加载完毕
 * @param panoramaView 当前全景视图
 * @param jsonStr 全景单点信息
 *
 */
//- (void)panoramaDidLoad:(BaiduPanoramaView *)panoramaView descreption:(NSString *)jsonStr {
//
//}

/**
 * @abstract 全景图加载失败
 * @param panoramaView 当前全景视图
 * @param error 加载失败的返回信息
 *
 */
//- (void)panoramaLoadFailed:(BaiduPanoramaView *)panoramaView error:(NSError *)error {
//
//}

/**
 * @abstract 全景图中的覆盖物点击事件
 * @param overlayId 覆盖物标识
 */
//- (void)panoramaView:(BaiduPanoramaView *)panoramaView overlayClicked:(NSString *)overlayId {
//
//}

//- (void)panoramaView:(BaiduPanoramaView *)panoramaView didReceivedMessage:(NSDictionary *)dict {
//    //全景拖动回调
//}

#pragma mark 室内相册回调

/**
 * @abstract 开发者自己设置的室内相册 View
 * @return 开发者创建的室内相册，如果不实现此代理，或者返回的 View 是空的话，那么仍然会调用默认相册
 */
//- (UIView *)indoorAlbumViewForPanoramaView:(BaiduPanoramaView *)panoramaView poiData:(BaiduPoiPanoData *)data {
//
//}

@end
