//
//  WASegmentedController.m
//  Weico
//
//  Created by YuAo on 6/21/13.
//  Copyright (c) 2013 北京微酷奥网络技术有限公司. All rights reserved.
//

#import "WASegmentedController.h"

typedef NS_ENUM(NSInteger, WASegmentedControllerAnimatedTransitionDirection) {
    WASegmentedControllerAnimatedTransitionDirectionUnknown,
    WASegmentedControllerAnimatedTransitionDirectionFromLeftToRight,
    WASegmentedControllerAnimatedTransitionDirectionFromRightToLeft
};

@interface WASegmentedControllerAnimatedTransitionContext : NSObject <UIViewControllerContextTransitioning>

@property (nonatomic, copy) void (^completionHandler)(BOOL completed);

@property (nonatomic, copy) void (^interactiveTransitionCompletionHandler)(void);
@property (nonatomic, copy) void (^interactiveTransitionCancellationHandler)(void);

@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic, getter=isInteractive) BOOL interactive;

@property (nonatomic,weak) UIView *containerView;
@property (nonatomic,copy) NSDictionary *viewControllers;

@property (nonatomic) CGRect initalFrameOfFromView;
@property (nonatomic) CGRect initalFrameOfToView;

@property (nonatomic) CGRect finialFrameOfFromView;
@property (nonatomic) CGRect finialFrameOfToView;

@property (nonatomic) WASegmentedControllerAnimatedTransitionDirection direction;

@property (nonatomic, getter = isCancelled) BOOL cancelled;

@end

@implementation WASegmentedControllerAnimatedTransitionContext

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationCustom;
}

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController direction:(WASegmentedControllerAnimatedTransitionDirection)direction {
	
	if ((self = [super init])) {
		self.containerView = fromViewController.view.superview;
		self.viewControllers = @{
                                 UITransitionContextFromViewControllerKey:fromViewController,
                                 UITransitionContextToViewControllerKey:toViewController,
                                 };
		
        self.direction = direction;
        [self updateFramesWithInteractiveTransitionPercentComplete:0];
	}
	
	return self;
}

- (void)updateFramesWithInteractiveTransitionPercentComplete:(double)percentComplete {
    CGFloat travelDistance = 0;
    switch (self.direction) {
        case WASegmentedControllerAnimatedTransitionDirectionFromLeftToRight:
            travelDistance = self.containerView.bounds.size.width;
            break;
        case WASegmentedControllerAnimatedTransitionDirectionFromRightToLeft:
            travelDistance = -self.containerView.bounds.size.width;
            break;
        default:
            break;
    }
    
    CGRect initalFrameOfFromView = self.containerView.bounds;
    CGRect initalFrameOfToView = CGRectOffset(self.containerView.bounds, -travelDistance, 0);
    CGRect finalFrameOfFromView = CGRectOffset(self.containerView.bounds, travelDistance, 0);
    CGRect finalFrameOfToView = initalFrameOfFromView;
    
    self.initalFrameOfFromView = CGRectOffset(initalFrameOfFromView, travelDistance * percentComplete, 0);
    self.initalFrameOfToView = CGRectOffset(initalFrameOfToView, travelDistance * percentComplete, 0);
    self.finialFrameOfFromView = finalFrameOfFromView;
    self.finialFrameOfToView = finalFrameOfToView;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
		return self.initalFrameOfFromView;
	} else {
		return self.initalFrameOfToView;
	}
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
		return self.finialFrameOfFromView;
	} else {
		return self.finialFrameOfToView;
	}
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.viewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
	if (self.completionHandler) {
		self.completionHandler(didComplete);
	}
}

- (BOOL)transitionWasCancelled {
    return self.isCancelled;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [self updateFramesWithInteractiveTransitionPercentComplete:percentComplete];
}

- (void)finishInteractiveTransition {
    if (self.interactiveTransitionCompletionHandler) {
        self.interactiveTransitionCompletionHandler();
    }
}

- (void)cancelInteractiveTransition {
    self.cancelled = YES;
    [self updateInteractiveTransition:0];
    if (self.interactiveTransitionCancellationHandler) {
        self.interactiveTransitionCancellationHandler();
    }
}


@synthesize targetTransform;

@end

@interface WASegmentedControllerAnimatedTransition :  NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation WASegmentedControllerAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGRect initalFrameOfToView = [transitionContext initialFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    CGRect finalFrameOfToView = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    CGFloat movingDistance = ABS(CGRectGetMinX(initalFrameOfToView) - CGRectGetMinX(finalFrameOfToView));
    return 0.3 * (movingDistance/CGRectGetWidth([UIScreen mainScreen].bounds));
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
	UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	
    if ([transitionContext transitionWasCancelled]) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromViewController.view.frame = [transitionContext initialFrameForViewController:fromViewController];
            toViewController.view.frame = [transitionContext initialFrameForViewController:toViewController];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        toViewController.view.frame = [transitionContext initialFrameForViewController:toViewController];
        fromViewController.view.frame = [transitionContext initialFrameForViewController:fromViewController];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromViewController.view.frame = [transitionContext finalFrameForViewController:fromViewController];
            toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end


@interface WASegmentedControllerInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>

@property (nonatomic,strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic) CGFloat percentComplete;

@end

@implementation WASegmentedControllerInteractiveTransition

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    self.percentComplete = percentComplete;
    
    [self.transitionContext updateInteractiveTransition:percentComplete];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromViewController.view.frame = [self.transitionContext initialFrameForViewController:fromViewController];
    toViewController.view.frame = [self.transitionContext initialFrameForViewController:toViewController];
}

- (void)cancelInteractiveTransition {
    [self.transitionContext cancelInteractiveTransition];
}

- (void)finishInteractiveTransition {
    [self.transitionContext finishInteractiveTransition];
}

@end


@interface WASegmentedController ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong,readwrite) UISegmentedControl *segmentedControl;
@property (nonatomic,readwrite,weak) UIViewController *activeViewController;
@property (nonatomic,weak) UIView *contentView;

@property (nonatomic,weak) UIPanGestureRecognizer *interactivePanGestureRecognizer;
@property (nonatomic) CGPoint interactivePanInitialPoint;
@property (nonatomic) WASegmentedControllerAnimatedTransitionDirection interactivePanDirection;
@property (nonatomic,strong) WASegmentedControllerAnimatedTransitionContext *interactiveTransitionContext;
@property (nonatomic,strong) WASegmentedControllerInteractiveTransition *interactiveTransitionAnimator;

@end

@implementation WASegmentedController

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *viewController in _viewControllers) {
        if (viewController.parentViewController == self) {
            [viewController willMoveToParentViewController:nil];
            if (viewController.isViewLoaded) [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    _viewControllers = viewControllers.copy;
    self.activeViewController = nil;
    if (self.isViewLoaded) {
        [self configureSegmentedControlUsingViewControllers:viewControllers];
    }
}

- (void)setActiveViewController:(UIViewController *)activeViewController {
    _activeViewController = activeViewController;
    if (self.shouldUseRightBarButtonItemOfActiveViewController) {
        self.navigationItem.rightBarButtonItems = self.activeViewController.navigationItem.rightBarButtonItems;
    }
    if (self.shouldUseLeftBarButtonItemOfActiveViewController) {
        self.navigationItem.leftBarButtonItems = self.activeViewController.navigationItem.leftBarButtonItems;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)configureSegmentedControlUsingViewControllers:(NSArray *)viewControllers {
    [self.segmentedControl removeAllSegments];
    for (UIViewController *viewController in viewControllers.reverseObjectEnumerator.allObjects) {
        [self.segmentedControl insertSegmentWithTitle:viewController.title atIndex:0 animated:NO];
    }
    [self.segmentedControl sizeToFit];
    if (self.segmentedControl.numberOfSegments) {
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    [self segmentedControlValueChanged];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
    
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[]];
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    self.segmentedControl = segmentedControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureSegmentedControlUsingViewControllers:self.viewControllers];
    
    UIPanGestureRecognizer *interactivePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    interactivePanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:interactivePanGestureRecognizer];
    self.interactivePanGestureRecognizer = interactivePanGestureRecognizer;
}

- (void)setInteractivePanDirection:(WASegmentedControllerAnimatedTransitionDirection)interactivePanDirection {
    if (_interactivePanDirection == interactivePanDirection) return;
    
    _interactivePanDirection = interactivePanDirection;
    
    [self.interactiveTransitionAnimator cancelInteractiveTransition];
    self.interactiveTransitionAnimator = nil;
    self.interactiveTransitionContext = nil;
    
    
    UIViewController *toViewController = nil;
    UIViewController *fromViewController = self.activeViewController;

    switch (interactivePanDirection) {
        case WASegmentedControllerAnimatedTransitionDirectionFromLeftToRight:{
            if (self.segmentedControl.selectedSegmentIndex - 1 >= 0) {
                toViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex - 1];
            }
        } break;
        case WASegmentedControllerAnimatedTransitionDirectionFromRightToLeft:{
            if (self.segmentedControl.selectedSegmentIndex + 1 < (NSInteger)self.segmentedControl.numberOfSegments) {
                toViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex + 1];
            }
        } break;
        default:
            break;
    }
    
    if (toViewController) {
        void (^viewControllerTransitionPrepare)(void) = ^{
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:willChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self willChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
            }
            
            [fromViewController willMoveToParentViewController:nil];
            [self addChildViewController:toViewController];
            toViewController.view.frame = self.contentView.bounds;
            toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:toViewController.view];
            [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:toViewController];
            
            self.segmentedControl.userInteractionEnabled = NO;
        };
        
        void(^viewControllerTransitionComplete)(void) = ^ {
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            [toViewController didMoveToParentViewController:self];
            self.activeViewController = toViewController;
            
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:didChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self didChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
            }
            
            self.segmentedControl.userInteractionEnabled = YES;
            
            self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:self.activeViewController];
        };
        
        void(^viewControllerTransitionRollback)(void) = ^{
            [toViewController willMoveToParentViewController:nil];
            [self addChildViewController:fromViewController];
            fromViewController.view.frame = self.contentView.bounds;
            fromViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:fromViewController.view];
            [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:fromViewController];
            
            [toViewController.view removeFromSuperview];
            [toViewController removeFromParentViewController];
            [fromViewController didMoveToParentViewController:self];
            self.activeViewController = fromViewController;
            
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:didChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self didChangeContentViewControllerFromViewController:toViewController toViewController:fromViewController];
            }
            
            self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:self.activeViewController];
        };
        
        
        viewControllerTransitionPrepare();
        
        id<UIViewControllerAnimatedTransitioning>animator = [[WASegmentedControllerAnimatedTransition alloc] init];
        id<UIViewControllerInteractiveTransitioning>interactiveAnimator = [[WASegmentedControllerInteractiveTransition alloc] init];
        WASegmentedControllerAnimatedTransitionContext *transitionContext = [[WASegmentedControllerAnimatedTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController direction:interactivePanDirection];
        
        transitionContext.animated = YES;
        transitionContext.interactive = YES;
        
        transitionContext.completionHandler = ^(BOOL didComplete) {
            viewControllerTransitionComplete();
            if ([animator respondsToSelector:@selector(animationEnded:)]) {
                [animator animationEnded:didComplete];
            }
            if (!didComplete) {
                viewControllerTransitionRollback();
            }
        };

        typeof(transitionContext) __weak weakTransitionContext = transitionContext;
        [transitionContext setInteractiveTransitionCompletionHandler:^{
            [animator animateTransition:weakTransitionContext];
        }];
        [transitionContext setInteractiveTransitionCancellationHandler:^{
            [animator animateTransition:weakTransitionContext];
        }];
        self.interactiveTransitionContext = transitionContext;
        self.interactiveTransitionAnimator = interactiveAnimator;
        [interactiveAnimator startInteractiveTransition:transitionContext];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            //Begin
            self.interactivePanDirection = WASegmentedControllerAnimatedTransitionDirectionUnknown;
            self.interactivePanInitialPoint = [sender locationInView:self.view];
        }break;
        case UIGestureRecognizerStateChanged:{
            //Change
            CGPoint currentPoint = [sender locationInView:self.view];
            [UIView performWithoutAnimation:^{
                if (currentPoint.x > self.interactivePanInitialPoint.x) {
                    self.interactivePanDirection = WASegmentedControllerAnimatedTransitionDirectionFromLeftToRight;
                } else {
                    self.interactivePanDirection = WASegmentedControllerAnimatedTransitionDirectionFromRightToLeft;
                }
            }];
            double progress = ABS(currentPoint.x - self.interactivePanInitialPoint.x)/CGRectGetWidth(self.contentView.bounds);
            [self.interactiveTransitionAnimator updateInteractiveTransition:progress];
        }break;
        default:{
            //End
            CGPoint velocity = [sender velocityInView:self.view];
            if (velocity.x < -20) {
                if (self.interactivePanDirection == WASegmentedControllerAnimatedTransitionDirectionFromRightToLeft) {
                    [self.interactiveTransitionAnimator finishInteractiveTransition];
                } else {
                    [self.interactiveTransitionAnimator cancelInteractiveTransition];
                }
            } else if (velocity.x > 20) {
                if (self.interactivePanDirection == WASegmentedControllerAnimatedTransitionDirectionFromLeftToRight) {
                    [self.interactiveTransitionAnimator finishInteractiveTransition];
                } else {
                    [self.interactiveTransitionAnimator cancelInteractiveTransition];
                }
            } else {
                CGPoint currentPoint = [sender locationInView:self.view];
                double progress = ABS(currentPoint.x - self.interactivePanInitialPoint.x)/CGRectGetWidth(self.contentView.bounds);
                if (progress > 0.4) {
                    [self.interactiveTransitionAnimator finishInteractiveTransition];
                } else {
                    [self.interactiveTransitionAnimator cancelInteractiveTransition];
                }
            }
            self.interactiveTransitionContext = nil;
            self.interactiveTransitionAnimator = nil;
        }break;
    }
}

#pragma mark - GestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void)segmentedControlValueChanged {
    if (self.viewControllers.count && self.segmentedControl.selectedSegmentIndex >= 0 && self.segmentedControl.selectedSegmentIndex < (NSInteger)self.viewControllers.count) {
        UIViewController *toViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex];
        UIViewController *fromViewController = self.activeViewController;
        
        if ((fromViewController != toViewController && fromViewController.parentViewController == self) || !fromViewController) {
            
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:willChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self willChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
            }
            
            [fromViewController willMoveToParentViewController:nil];
            [self addChildViewController:toViewController];
            toViewController.view.frame = self.contentView.bounds;
            toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:toViewController.view];
            [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:toViewController];
            
            self.segmentedControl.userInteractionEnabled = NO;

            void(^viewControllerTransitionCompletedHandler)(void) = ^(void) {
                [fromViewController.view removeFromSuperview];
                [fromViewController removeFromParentViewController];
                [toViewController didMoveToParentViewController:self];
                self.activeViewController = toViewController;
                
                if ([self.delegate respondsToSelector:@selector(segmentedViewController:didChangeContentViewControllerFromViewController:toViewController:)]) {
                    [self.delegate segmentedViewController:self didChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
                }
                
                self.segmentedControl.userInteractionEnabled = YES;
            };
            

            if (fromViewController) {
                id<UIViewControllerAnimatedTransitioning>animator = [[WASegmentedControllerAnimatedTransition alloc] init];
                
                NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
                NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
                WASegmentedControllerAnimatedTransitionContext *transitionContext = [[WASegmentedControllerAnimatedTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController direction:(toIndex > fromIndex)?WASegmentedControllerAnimatedTransitionDirectionFromRightToLeft:WASegmentedControllerAnimatedTransitionDirectionFromLeftToRight];
                
                transitionContext.animated = YES;
                transitionContext.interactive = NO;
                transitionContext.completionHandler = ^(BOOL didComplete) {
                    viewControllerTransitionCompletedHandler();
                    if ([animator respondsToSelector:@selector(animationEnded:)]) {
                        [animator animationEnded:didComplete];
                    }
                };
                [animator animateTransition:transitionContext];
            } else {
                viewControllerTransitionCompletedHandler();
            }
        }
    }
}

- (void)selectViewControllerAtIndex:(NSInteger)index {
    self.segmentedControl.selectedSegmentIndex = index;
    [self segmentedControlValueChanged];
}

- (void)makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:(UIViewController *)viewController {
        SEL computeAndApplyInsetSelector = NSSelectorFromString([@[ @"_computeAndApply", @"ScrollContentInsetDeltaForViewController:"] componentsJoinedByString:@""]);
        if ([self.navigationController respondsToSelector:computeAndApplyInsetSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.navigationController performSelector:computeAndApplyInsetSelector withObject:viewController];
#pragma clang diagnostic pop
        }
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    if (NSFoundationVersionNumber > 1047.25/*7.1*/) {
        return self.activeViewController.automaticallyAdjustsScrollViewInsets;
    } else {
        [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:self.activeViewController];
        return NO;
    }
}

@end
