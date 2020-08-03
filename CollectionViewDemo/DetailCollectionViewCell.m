//
//  DetailCollectionViewCell.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/21.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DetailCollectionViewCell.h"
#import <Masonry/Masonry.h>

@implementation DetailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor lightGrayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.textLabel = titleLabel;
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
        }];
    }
    return self;
}

@end
