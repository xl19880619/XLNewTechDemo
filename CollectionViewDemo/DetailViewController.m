//
//  DetailViewController.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/21.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailCollectionViewLayout.h"
#import <Masonry/Masonry.h>
#import "DetailCollectionViewCell.h"
#import "DetailSectionTitleCollectionView.h"
#import "DetailHeaderCollectionViewCell.h"

@implementation DetailItem

@end

@interface DetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) DetailCollectionViewLayout *layout;

@property (nonatomic, copy) NSArray<DetailItem *> *items;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.layout = [[DetailCollectionViewLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    collectionView.backgroundColor = [UIColor grayColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;
//    collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.collectionView registerClass:[DetailHeaderCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([DetailHeaderCollectionViewCell class])];
    [self.collectionView registerClass:[DetailCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([DetailCollectionViewCell class])];
    [self.collectionView registerClass:[DetailSectionTitleCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([DetailSectionTitleCollectionView class])];
    
    NSMutableArray *items = [NSMutableArray array];
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.isHeader = YES;
        [items addObject:item];
    }
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.itemValue = @"itemValue 01 itemValue 01 \n itemValue 01 \n itemValue 01 \n itemValue 01 \n itemValue 01 \n itemValue 01 \n itemValue 01 \n itemValue 01";
        item.useShadow = YES;
        [items addObject:item];
    }
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.itemValue = @"itemValue 02 \n itemValue 02 \n itemValue 02 \n itemValue 02";
        item.useShadow = YES;
        [items addObject:item];
    }
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.itemValue = @"itemValue 03";
        item.useShadow = NO;
        [items addObject:item];
    }
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.sectionTitle = @"sectionTitle 04";
        item.itemValue = @"itemValue 04 itemValue 04 \n itemValue 04 \n itemValue 04";
        item.useShadow = YES;
        item.containSection = YES;
        [items addObject:item];
    }
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.sectionTitle = @"sectionTitle 06";
        item.itemValue = @"itemValue 06 itemValue 06 \n itemValue 04 \n itemValue 04";
        item.useShadow = YES;
//        item.containSection = YES;
        [items addObject:item];
    }
    {
        DetailItem *item = [[DetailItem alloc] init];
        item.itemValue = @"itemValue 05 itemValue 05 \n itemValue 05 itemValue 05";
        [items addObject:item];
    }
    self.items = items.copy;
    self.layout.shadowSections = items.copy;
}

- (void)buttonAction {
    NSLog(@"buttonAction");
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailItem *detailItem = self.items[indexPath.section];
    if (detailItem.isHeader) {
        DetailHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DetailHeaderCollectionViewCell class]) forIndexPath:indexPath];
        return cell;
    }
    DetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DetailCollectionViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = detailItem.itemValue;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DetailItem *detailItem = self.items[indexPath.section];
        if (detailItem.sectionTitle.length) {
            DetailSectionTitleCollectionView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([DetailSectionTitleCollectionView class]) forIndexPath:indexPath];
            titleView.titleLabel.text = detailItem.sectionTitle;
            return titleView;
        }
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailItem *detailItem = self.items[indexPath.section];
    if (detailItem.isHeader) {
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetWidth(self.collectionView.frame) /4.0 * 3);
    }
    CGFloat width = CGRectGetWidth(collectionView.frame) - 15 * 2;
    if (detailItem.itemValue.length) {
        CGRect frame = [detailItem.itemValue boundingRectWithSize:CGSizeMake(width - 10 * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
        return CGSizeMake(width, ceil(frame.size.height) + 10 * 2);
    }

    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    DetailItem *detailItem = self.items[section];
    if (detailItem.useShadow) {
        if (section == 1) {
            return UIEdgeInsetsMake(-20, 15, 20, 15);
        }
        return UIEdgeInsetsMake(20, 15, 20, 15);
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DetailItem *detailItem = self.items[section];
    if (detailItem.sectionTitle.length) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 23 + 5 * 2);
    }
    return CGSizeZero;
}

@end
