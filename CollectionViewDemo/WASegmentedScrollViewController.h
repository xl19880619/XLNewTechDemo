//
//  WASegmentedScrollViewController.h
//  WeicoSegmentedScrollViewControllerDemo
//
//  Created by Jackie CHEUNG on 14-7-14.
//  Copyright (c) 2014年 weico. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WASegmentedScrollViewController;
@protocol WASegmentedScrollViewControllerDelegate <NSObject>
@optional
- (void)scrollViewController:(WASegmentedScrollViewController *)viewController willSelecteViewControllerAtIndex:(NSInteger)index;
- (void)scrollViewController:(WASegmentedScrollViewController *)viewController didSelecteViewControllerAtIndex:(NSInteger)index;

- (CGPoint)scrollViewController:(WASegmentedScrollViewController *)viewController targetContentOffsetToResetForProposedContentOffset:(CGPoint)proposedContentOffset;

@end


@interface WASegmentedScrollViewController : UIViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

- (void)selectViewControllerAtIndex:(NSUInteger)selectIndex;

@property (nonatomic, readonly) UIScrollView *containerView;

@property (nonatomic, weak) id<WASegmentedScrollViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;

@property (nonatomic, copy) NSArray *viewControllers;

@property (nonatomic, readonly) UIViewController *activeViewController;

@property (nonatomic, weak) UIView *headerView;

@property (nonatomic) BOOL resetContentOffsetWhenChangeActiveViewController;

@end
