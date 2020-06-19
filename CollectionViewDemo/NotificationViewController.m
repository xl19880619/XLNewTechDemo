//
//  NotificationViewController.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/1.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "NotificationViewController.h"
#import "BTDWeakProxy.h"

@interface NotificationViewController ()

@property (nonatomic, strong) NSString *infoString;

@property (nonatomic, strong) id observer;

@end

@implementation NotificationViewController

- (void)dealloc {
    NSLog(@"NotificationViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSelf)];
    
    [self addObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.observer = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (void)addObserver {
    __weak typeof(self) weakSelf = self;
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"testForKey" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"recieve notification");
        weakSelf.infoString = @"test";
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
