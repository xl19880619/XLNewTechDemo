//
//  CoreInfoCollectionViewCell.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "CoreInfoCollectionViewCell.h"

@implementation CoreInfoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor blueColor];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor lightGrayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0, 10, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)-20);
}

@end
