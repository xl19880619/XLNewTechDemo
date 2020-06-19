//
//  LeftAlignedCollectionViewFlowLayout.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "LeftAlignedCollectionViewFlowLayout.h"

@implementation LeftAlignedCollectionViewFlowLayout

/**
 let attributes = super.layoutAttributesForElements(in: rect)

 var leftMargin = sectionInset.left
 var maxY: CGFloat = -1.0
 attributes?.forEach { layoutAttribute in
     if layoutAttribute.frame.origin.y >= maxY {
         leftMargin = sectionInset.left
     }

     layoutAttribute.frame.origin.x = leftMargin

     leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
     maxY = max(layoutAttribute.frame.maxY , maxY)
 }

 return attributes
 */
- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *attributes = [super layoutAttributesForElementsInRect:rect];
    
//    CGFloat leftMargin = self.sectionInset.left;
//    CGFloat maxY = -1.0;
    for (UICollectionViewLayoutAttributes *layoutAttribute in attributes) {
        if (layoutAttribute.frame.origin.x > 0 && layoutAttribute.frame.origin.x < floor(CGRectGetWidth(self.collectionView.frame)/2.0)) {
            CGRect frame = layoutAttribute.frame;
            frame.origin.x = 0;
            layoutAttribute.frame = frame;
        }
    }
    
    return attributes;
}

@end
