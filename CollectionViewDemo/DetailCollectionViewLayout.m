//
//  DetailCollectionViewLayout.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/7/29.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DetailCollectionViewLayout.h"
#import "FHBuildingDetailShadowView.h"
#import "DetailViewController.h"

@implementation DetailCollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerClass:[FHBuildingDetailShadowView class] forDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class])];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newArray = array.mutableCopy;
    __block NSMutableArray *sections = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.indexPath.section == 0) {
            obj.zIndex = -2;
        }
        DetailItem *item = self.shadowSections[obj.indexPath.section];
        if (item.useShadow && ![sections containsObject:@(obj.indexPath.section)]) {
            [sections addObject:@(obj.indexPath.section)];
            UICollectionViewLayoutAttributes *newAttrs = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class]) atIndexPath:[NSIndexPath indexPathForItem:0 inSection:obj.indexPath.section]];
            [newArray addObject:newAttrs];
        }
    }];
    // 设置 Item 和 SupplementaryView
      
    // 设置 DecorationView
    
    return newArray;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
//
//    if ([elementKind isEqualToString:NSStringFromClass([FHBuildingDetailShadowView class])] && [self.collectionView numberOfSections] - 1 == indexPath.section) {
//        DecorationLayoutAttributes * attributes = [DecorationLayoutAttributes layoutAttributesForDecorationViewOfKind: FDRFrontDecorationReusableView withIndexPath: indexPath];
//        // 通过属性，外部设置装饰视图的实际图片 ( 后有介绍 )
//        attributes.imgUrlStr = self.imgUrlString;
//       // 这里，装饰视图的位置是固定的
//        CGFloat heightOffset = 16;
//        attributes.frame = CGRectMake(0, KScreenWidth * 0.5 - heightOffset, KScreenWidth, 102 + heightOffset);
//        attributes.zIndex -= 1;
//        return attributes;
//    }
//    return nil;
//}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (!self.shadowSections.count) {
        return nil;
    }
    
    if (![elementKind isEqualToString:NSStringFromClass([FHBuildingDetailShadowView class])]) {
        return nil;
    }
    DetailItem *item = self.shadowSections[indexPath.section];
    if (!item.useShadow) {
        return nil;
    }
    
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
    UICollectionViewLayoutAttributes *newDecorationAttributes = [decorationAttributes copy];
    
    NSIndexPath *indexPathFirst = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:indexPath.section] inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *attrsFirst = [self layoutAttributesForItemAtIndexPath:indexPathFirst];
    UICollectionViewLayoutAttributes *attrsLast = [self layoutAttributesForItemAtIndexPath:indexPathLast];

    newDecorationAttributes.frame = CGRectMake(attrsFirst.frame.origin.x - 15, attrsFirst.frame.origin.y - 20, self.collectionView.frame.size.width, attrsLast.frame.origin.y-attrsFirst.frame.origin.y + 40);
    UICollectionViewLayoutAttributes *sectionAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    if (sectionAttrs && item.containSection) {
        CGRect frame = newDecorationAttributes.frame;
        frame.origin.y = sectionAttrs.frame.origin.y - 20;
        frame.size.height += sectionAttrs.frame.size.height + 25;
        newDecorationAttributes.frame = frame;
    }
    // 想要作为背景图像，就一定要将其 zIndex 设置为 -1
    newDecorationAttributes.zIndex = -1;
    return newDecorationAttributes;
}
@end
