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

@interface ViewController ()

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"A little change", nil);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stackView = [[UIStackView alloc] initWithFrame:self.view.bounds];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.distribution = UIStackViewDistributionEqualSpacing;
    [self.view addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    {
        UIButton *stackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stackButton addTarget:self action:@selector(pushStack:) forControlEvents:UIControlEventTouchUpInside];
        stackButton.backgroundColor = [UIColor redColor];
        [stackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [stackButton setTitle:@"UIStackView" forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:stackButton];
        [stackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(44);
        }];
    }
    
    {
        UIButton *stackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stackButton addTarget:self action:@selector(pushCoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        stackButton.backgroundColor = [UIColor blackColor];
        [stackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [stackButton setTitle:@"CoreInfo" forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:stackButton];
        [stackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(44);
        }];
    }
    
    {
        UIButton *stackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stackButton addTarget:self action:@selector(pushDetail:) forControlEvents:UIControlEventTouchUpInside];
        stackButton.backgroundColor = [UIColor yellowColor];
        [stackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [stackButton setTitle:@"Detail" forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:stackButton];
        [stackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(44);
        }];
    }
    
    {
        UIButton *stackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stackButton addTarget:self action:@selector(pushPanorama:) forControlEvents:UIControlEventTouchUpInside];
        stackButton.backgroundColor = [UIColor greenColor];
        [stackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [stackButton setTitle:@"Panorama" forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:stackButton];
        [stackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(44);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}


- (void)pushStack:(id)sender {
    StackViewController *stackVC = [[StackViewController alloc] initWithNibName:@"StackViewController" bundle:nil];
    [self.navigationController pushViewController:stackVC animated:YES];
}

- (void)pushCoreInfo:(id)sender {
    CoreInfoViewController *coreInfoVC = [[CoreInfoViewController alloc] init];
    [self.navigationController pushViewController:coreInfoVC animated:YES];
}

- (void)pushDetail:(id)sender {
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)pushPanorama:(id)sender {
    PanoramaViewController *panoramaVC = [[PanoramaViewController alloc] init];
    [self.navigationController pushViewController:panoramaVC animated:YES];
}

@end
