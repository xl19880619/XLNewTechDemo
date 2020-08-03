//
//  FHBuildingDetailShadowView.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/7/29.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "FHBuildingDetailShadowView.h"
#import <Masonry/Masonry.h>

@implementation FHBuildingDetailShadowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *shadowImageView = [[UIImageView alloc] init];
        shadowImageView.image = [[UIImage imageNamed:@"top_left_right_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(50,50,50,50) resizingMode:UIImageResizingModeStretch];
        [self addSubview:shadowImageView];
        [shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

@end
