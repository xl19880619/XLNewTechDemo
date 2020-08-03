//
//  StackViewController.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "StackViewController.h"
#import <Masonry/Masonry.h>

@interface StackViewController ()
@property (strong, nonatomic) IBOutlet UILabel *douyinTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *osVersionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *douyinSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *osVersionSwitch;

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UIButton *codeLoginButton;
@property (nonatomic, strong) UIButton *douyinLoginButton;
@property (nonatomic, strong) UIButton *appleLoginButton;

@property (nonatomic, copy) void (^block) (void);
@end

@implementation StackViewController

- (UIButton *)codeLoginButton {
    if (!_codeLoginButton) {
        _codeLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_codeLoginButton setImage:[UIImage imageNamed:@"login_mobile_icon"] forState:UIControlStateNormal];
        [_codeLoginButton addTarget:self action:@selector(codeLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [_codeLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(38, 38));
        }];
    }
    return _codeLoginButton;
}

- (UIButton *)douyinLoginButton {
    if (!_douyinLoginButton) {
        _douyinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_douyinLoginButton setImage:[UIImage imageNamed:@"douyin_login_common_icon"] forState:UIControlStateNormal];
        [_douyinLoginButton addTarget:self action:@selector(douyinLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [_douyinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(38, 38));
        }];
    }
    return _douyinLoginButton;
}

- (UIButton *)appleLoginButton {
    if (!_appleLoginButton) {
        _appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_appleLoginButton setImage:[UIImage imageNamed:@"apple_login_icon"] forState:UIControlStateNormal];
        [_appleLoginButton addTarget:self action:@selector(appleLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [_appleLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(138, 38));
        }];
    }
    return _appleLoginButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"UIStackView", nil);
    
    self.stackView = [[UIStackView alloc] init];
    self.stackView.distribution = UIStackViewDistributionEqualSpacing;
    self.stackView.alignment = UIStackViewAlignmentCenter;
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    [self.view addSubview:self.stackView];

    self.douyinSwitch.on = NO;
    self.osVersionSwitch.on = NO;
    [self reloadStackSubviews];
}

- (void)buttonAction {
    
}

- (void)reloadStackSubviews {
    CGFloat stackViewWidth = 38;

    [self.stackView addArrangedSubview:self.codeLoginButton];
    if (self.douyinSwitch.isOn) {
        stackViewWidth += (38+20);
        [self.stackView addArrangedSubview:self.douyinLoginButton];
    }
    
    if (self.osVersionSwitch.isOn) {
        stackViewWidth += (138+20);
        [self.stackView addArrangedSubview:self.appleLoginButton];
    }
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(CGRectGetMaxY(self.osVersionLabel.frame) + 40);
        make.width.mas_equalTo(stackViewWidth);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Action

- (IBAction)douyinSwitchAction:(id)sender {
//    self.douyinSwitch.on = !self.douyinSwitch.isOn;
    CGFloat stackViewWidth = 38;
    if (self.osVersionSwitch.isOn) {
        stackViewWidth += (138+20);
    }
    if (self.douyinSwitch.isOn) {
        stackViewWidth += (38+20);
        [self.stackView insertArrangedSubview:self.douyinLoginButton atIndex:1];
    } else {
        [self.stackView removeArrangedSubview:self.douyinLoginButton];
        [self.douyinLoginButton removeFromSuperview];
    }
    
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(stackViewWidth);
    }];
}

- (IBAction)osVersionSwithAction:(id)sender {
//    self.osVersionSwitch.on = !self.osVersionSwitch.isOn;
    
    CGFloat stackViewWidth = 38;
    if (self.douyinSwitch.isOn) {
        stackViewWidth += (38+20);
    }
    if (self.osVersionSwitch.isOn) {
        stackViewWidth += (138+20);
        [self.stackView addArrangedSubview:self.appleLoginButton];
    } else {
        [self.stackView removeArrangedSubview:self.appleLoginButton];
        [self.appleLoginButton removeFromSuperview];
    }
    
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(stackViewWidth);
    }];
}

- (void)codeLoginAction {
    
}

- (void) douyinLoginAction {
    
}

- (void)appleLoginAction {
    
}

@end
