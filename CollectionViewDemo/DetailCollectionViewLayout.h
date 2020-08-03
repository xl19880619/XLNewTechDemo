//
//  DetailCollectionViewLayout.h
//  CollectionViewDemo
//
//  Created by bytedance on 2020/7/29.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class DetailItem;

@interface DetailCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) NSArray <DetailItem *>*shadowSections;

@end

NS_ASSUME_NONNULL_END
