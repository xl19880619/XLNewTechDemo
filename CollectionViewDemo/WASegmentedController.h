//
//  WASegmentedController.h
//  Weico
//
//  Created by YuAo on 6/21/13.
//  Copyright (c) 2013 北京微酷奥网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WASegmentedController;

@protocol WASegmentedViewControllerDelegate <NSObject>
@optional

- (void)segmentedViewController:(WASegmentedController *)segmentedViewController willChangeContentViewControllerFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

- (void)segmentedViewController:(WASegmentedController *)segmentedViewController didChangeContentViewControllerFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end


@interface WASegmentedController : UIViewController

@property (nonatomic,weak) id<WASegmentedViewControllerDelegate> delegate;

@property (nonatomic,strong,readonly) UISegmentedControl *segmentedControl;

@property (nonatomic,copy) NSArray *viewControllers;

@property (nonatomic,readonly,weak) UIViewController *activeViewController;

@property (nonatomic,readonly,weak) UIPanGestureRecognizer *interactivePanGestureRecognizer;

@property (nonatomic) BOOL shouldUseRightBarButtonItemOfActiveViewController;
@property (nonatomic) BOOL shouldUseLeftBarButtonItemOfActiveViewController;

- (void)selectViewControllerAtIndex:(NSInteger)index;

@end
