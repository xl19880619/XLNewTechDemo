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

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"A little change", nil);
    
}

- (IBAction)pushStack:(id)sender {
    StackViewController *stackVC = [[StackViewController alloc] init];
    [self.navigationController pushViewController:stackVC animated:YES];
}

- (IBAction)pushCoreInfo:(id)sender {
    CoreInfoViewController *coreInfoVC = [[CoreInfoViewController alloc] init];
    [self.navigationController pushViewController:coreInfoVC animated:YES];
}

- (IBAction)pushDetail:(id)sender {
}

@end
