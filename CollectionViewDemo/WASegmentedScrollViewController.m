//
//  WASegmentedScrollViewController.m
//  WeicoSegmentedScrollViewControllerDemo
//
//  Created by Jackie CHEUNG on 14-7-14.
//  Copyright (c) 2014年 weico. All rights reserved.
//

#import "WASegmentedScrollViewController.h"
#import "WASegmentedScrollContentView.h"
//#import <QattiApplicationKitUtilities/QattiApplicationKitUtilities.h>

static NSString *const contentSubviewContextLastContentOffsetKey = @"contentSubviewContextLastContentOffsetKey";
static NSString *const contentSubviewContextSubviewKey = @"contentSubviewContextSubviewKey";

@interface WASegmentedScrollViewController ()
@property (nonatomic, weak) WASegmentedScrollContentView *internalContainerView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableDictionary *contentSubviewContext;
@end

@implementation WASegmentedScrollViewController

- (void)dealloc {
    self.viewControllers = nil;
    self.contentSubviewContext = nil;
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    self = [super init];
    if(self) {
        self.viewControllers = viewControllers;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    WASegmentedScrollContentView *containerView = [[WASegmentedScrollContentView alloc] init];
    containerView.frame = self.view.bounds;
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    containerView.showsHorizontalScrollIndicator = NO;
    containerView.showsVerticalScrollIndicator = NO;
    self.internalContainerView = containerView;
    
    [self.view addSubview:containerView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    [self executeOnce:^{
//        if(self.viewControllers.count) [self selectViewControllerAtIndex:0];
//    } token:WAExecuteOnceUniqueTokenForCurrentContext];
}

#pragma mark - Getter & Setter
- (void)setViewControllers:(NSArray *)viewControllers {
    if(viewControllers == _viewControllers) return;
    _viewControllers = viewControllers;
    
    NSMutableDictionary *contentSubviewContext = [NSMutableDictionary dictionary];
    
    [self.segmentedControl removeAllSegments];
    for(NSUInteger index = 0; index < viewControllers.count; index++) {
        UIViewController *viewController = viewControllers[index];
        [self.segmentedControl insertSegmentWithTitle:viewController.title atIndex:index animated:NO];
        UIView *contentSubview = [self traverseSubviewsToGetViewOfClass:[UIScrollView class] inView:viewController.view];
        if(contentSubview)
            [contentSubviewContext setObject:[NSMutableDictionary dictionaryWithObject:contentSubview forKey:contentSubviewContextSubviewKey] forKey:@(index)];
        else
            [contentSubviewContext setObject:[NSMutableDictionary dictionaryWithObject:viewController.view forKey:contentSubviewContextSubviewKey] forKey:@(index)];
    }
    [self.segmentedControl sizeToFit];
    self.contentSubviewContext = contentSubviewContext;
    
    if(self.isViewLoaded && viewControllers.count) [self selectViewControllerAtIndex:0];
}

- (void)setHeaderView:(UIView *)headerView {
    if(_headerView == headerView) return;
    _headerView = headerView;
    
    [self.internalContainerView insertSubview:headerView atIndex:0];
}

- (UISegmentedControl *)segmentedControl {
    if(!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] init];
        [_segmentedControl addTarget:self action:@selector(segmentedControlValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UIScrollView *)containerView {
    return self.internalContainerView;
}

#pragma mark - Public Methods
- (void)selectViewControllerAtIndex:(NSUInteger)selectIndex {
    [self.segmentedControl setSelectedSegmentIndex:selectIndex];
    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (UIViewController *)activeViewController {
    return self.viewControllers[self.segmentedControl.selectedSegmentIndex];
}

#pragma Private Methods
- (UIView *)traverseSubviewsToGetViewOfClass:(Class)viewClass inView:(UIView *)view{
    if(!view) return nil;
    
    if([view isKindOfClass:[viewClass class]])
        return view;
    else
        return [self traverseSubviewsToGetViewOfClass:viewClass inView:view.subviews.firstObject];
}


- (void)segmentedControlValueDidChanged:(UISegmentedControl *)segmentedControl {
    
    UIViewController *selectedViewController = self.activeViewController;
    UIViewController *lastSelectedViewController = self.childViewControllers.lastObject;
    UIView *selectedView = self.contentSubviewContext[@(segmentedControl.selectedSegmentIndex)][contentSubviewContextSubviewKey];

    NSUInteger lastSelectedIndex = [self.viewControllers indexOfObject:lastSelectedViewController];
    UIView *lastSelectedView = lastSelectedViewController ? self.contentSubviewContext[@(lastSelectedIndex)][contentSubviewContextSubviewKey] : nil;
    self.contentSubviewContext[@(lastSelectedIndex)][contentSubviewContextLastContentOffsetKey] = [NSValue valueWithCGPoint:self.internalContainerView.contentOffset];
    
    if([self.delegate respondsToSelector:@selector(scrollViewController:willSelecteViewControllerAtIndex:)])
        [self.delegate scrollViewController:self willSelecteViewControllerAtIndex:segmentedControl.selectedSegmentIndex];
    
    [lastSelectedViewController beginAppearanceTransition:NO animated:NO];
    [lastSelectedViewController willMoveToParentViewController:nil];
    [lastSelectedViewController removeFromParentViewController];
    [lastSelectedView removeFromSuperview];
    [lastSelectedViewController endAppearanceTransition];

    [selectedViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:selectedViewController];
    
    [self.internalContainerView addSubview:selectedView];
    
    [selectedViewController didMoveToParentViewController:self];
    [selectedViewController endAppearanceTransition];
    
    NSValue *lastContentOffset = self.contentSubviewContext[@(segmentedControl.selectedSegmentIndex)][contentSubviewContextLastContentOffsetKey];
    if(self.resetContentOffsetWhenChangeActiveViewController && lastContentOffset) {
        if([self.delegate respondsToSelector:@selector(scrollViewController:targetContentOffsetToResetForProposedContentOffset:)])
            self.internalContainerView.contentOffset = [self.delegate scrollViewController:self targetContentOffsetToResetForProposedContentOffset:[lastContentOffset CGPointValue]];
        else
            self.internalContainerView.contentOffset = [lastContentOffset CGPointValue];
    }
    
    if([self.delegate respondsToSelector:@selector(scrollViewController:didSelecteViewControllerAtIndex:)])
        [self.delegate scrollViewController:self didSelecteViewControllerAtIndex:segmentedControl.selectedSegmentIndex];
}

@end
