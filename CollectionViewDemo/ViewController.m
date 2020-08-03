//
//  ViewController.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/5/29.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ViewController.h"
#import "NotificationViewController.h"
#import "StackViewController.h"
#import "CoreInfoViewController.h"
#import "PanoramaViewController.h"
#import <Masonry/Masonry.h>
#import "DetailViewController.h"

@interface DataSharedManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) NSArray *data;

@end

@implementation DataSharedManager

+ (instancetype)sharedManager {
    static DataSharedManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DataSharedManager alloc] init];
    });
    return _sharedManager;
}


@end

@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *countdownLabel;

@property (nonatomic) NSInteger seconds;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"A little change", nil);
    
//    [DataSharedManager sharedManager].data
//    [self testGroup];

//    NSMutableArray *houseDataItemsModel = [NSMutableArray array];
//    [houseDataItemsModel addObjectsFromArray:@[@"1",@"2"]];
//    NSArray *similarItems = @[@"10",@"11"];
//    NSRange range = NSMakeRange(10, [similarItems count]);
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
//    [houseDataItemsModel insertObjects:similarItems atIndexes:indexSet];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"load data refresh UI");
//    });
//
//    self.countdownLabel = [[UILabel alloc] init];
//    self.countdownLabel.backgroundColor = [UIColor redColor];
//    self.countdownLabel.textColor = [UIColor whiteColor];
//    [self.view addSubview:self.countdownLabel];
//    [self.countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.view);
//        make.bottom.mas_equalTo(-100);
//    }];
//    self.seconds = 60;
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
////        NSLog(@"hello timer:%@",timer);
//        self.countdownLabel.text = [NSString stringWithFormat:@"seconds: %ld",(long)self.seconds];
//        self.seconds --;
//        if (self.seconds <= 0) {
//            self.seconds = 60;
//        }
//    }];
    
    
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, <#dispatchQueue#>);
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, <#intervalInSeconds#> * NSEC_PER_SEC, <#leewayInSeconds#> * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(timer, ^{
//        <#code to be executed when timer fires#>
//    });
//    dispatch_resume(timer);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"ViewController viewWillAppear");
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSLog(@"ViewController viewWillAppear once");
//    });
}

- (void)testGroup {
//    __weak typeof(self) weakSelf = self;
//    __block NSError *requestError = nil;
    BOOL error = YES;
    dispatch_group_t group = dispatch_group_create();
    
//    dispatch_group_enter(group);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"group 111");
//        dispatch_group_leave(group);
//
//    });
//
//    dispatch_group_enter(group);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        if (error) {
//            NSLog(@"group 333");
//            dispatch_group_leave(group);
//            return;
//        }
//        NSLog(@"group 222");
//        dispatch_group_leave(group);
//    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        sleep(5);
        NSLog(@"group 111");
    });
    

    
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (error) {
            NSLog(@"group 333");
            return;
        }
        NSLog(@"group 222");
    });
    
    dispatch_group_wait(group, 0);
    
    NSLog(@"444");
    
//    dispatch_group_enter(group);
//    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        NSLog(@"group 111");
//        dispatch_group_leave(group);
//    });
//
////    dispatch
//    dispatch_group_enter(group);
//    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        NSLog(@"group 222");
//        dispatch_group_leave(group);
//    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{

        NSLog(@"group finished");
    });
}

- (IBAction)pushStack:(id)sender {
    StackViewController *stackVC = [[StackViewController alloc] initWithNibName:@"StackViewController" bundle:nil];
    [self.navigationController pushViewController:stackVC animated:YES];
}

- (IBAction)pushCoreInfo:(id)sender {
    CoreInfoViewController *coreInfoVC = [[CoreInfoViewController alloc] init];
    [self.navigationController pushViewController:coreInfoVC animated:YES];
}

- (IBAction)pushDetail:(id)sender {
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)pushPanorama:(id)sender {
    PanoramaViewController *panoramaVC = [[PanoramaViewController alloc] init];
    [self.navigationController pushViewController:panoramaVC animated:YES];
}

@end
