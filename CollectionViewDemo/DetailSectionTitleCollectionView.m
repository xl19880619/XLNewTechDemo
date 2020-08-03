//
//  DetailSectionTitleCollectionView.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/7/30.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DetailSectionTitleCollectionView.h"
#import <Masonry/Masonry.h>

@implementation DetailSectionTitleCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor blueColor];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor blackColor];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self);
        }];
    }
    return self;
}

@end
