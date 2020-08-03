//
//  WASegmentedScrollContentView.m
//  Weicoplus
//
//  Created by Jackie CHEUNG on 14-7-14.
//  Copyright (c) 2014年 Weico. All rights reserved.
//

#import "WASegmentedScrollContentView.h"

static void *KVOContext = &KVOContext;
@interface WASegmentedScrollContentView ()
@end

@implementation WASegmentedScrollContentView
#pragma mark - Private Methods
- (void)_setup {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

#pragma mark - Public Methods
- (void)dealloc {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _setup];
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    
    if ([subview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)subview;
        scrollView.scrollEnabled = NO;
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:KVOContext];
    } else {
        [subview addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionOld context:KVOContext];
        [subview addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionOld context:KVOContext];
    }
    [self setNeedsLayout];
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    if ([subview isKindOfClass:[UIScrollView class]]) {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:KVOContext];
    } else {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) context:KVOContext];
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) context:KVOContext];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // The logical vertical offset where the current subview (while iterating over all subviews)
    // must be positioned. Subviews are positioned below each other, in the order they were added
    // to the container. For scroll views, we reserve their entire contentSize.height as vertical
    // space. For non-scroll views, we reserve their current frame.size.height as vertical space.
    CGFloat yOffsetOfCurrentSubview = 0.0;
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            CGRect frame = scrollView.frame;
            CGPoint contentOffset = scrollView.contentOffset;
            
            // Translate the logical offset into the sub-scrollview's real content offset and frame size.
            // Methodology:
            
            // (1) As long as the sub-scrollview has not yet reached the top of the screen, set its scroll position
            // to 0.0 and position it just like a normal view. Its content scrolls naturally as the container
            // scroll view scrolls.
            if (self.contentOffset.y < yOffsetOfCurrentSubview) {
                contentOffset.y = 0.0;
                frame.origin.y = yOffsetOfCurrentSubview;
            } else {
            // (2) If the user has scrolled far enough down so that the sub-scrollview reaches the top of the
            // screen, position its frame at 0.0 and start adjusting the sub-scrollview's content offset to
            // scroll its content.
                contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview;
                frame.origin.y = self.contentOffset.y;
            }
            
            // (3) The sub-scrollview's frame should never extend beyond the bottom of the screen, even if its
            // content height is potentially much greater. When the user has scrolled so far that the remaining
            // content height is smaller than the height of the screen, adjust the frame height accordingly.
            CGFloat remainingBoundsHeight = fmax(CGRectGetMaxY(self.bounds) - CGRectGetMinY(frame), 0.0);
            CGFloat remainingContentHeight = fmax((scrollView.contentSize.height + scrollView.contentInset.bottom) - contentOffset.y, 0.0);
            frame.size.height = fmin(remainingBoundsHeight, remainingContentHeight);
            frame.size.width = self.bounds.size.width;
            
            scrollView.frame = frame;
            scrollView.contentOffset = contentOffset;
            
            yOffsetOfCurrentSubview += (scrollView.contentSize.height + scrollView.contentInset.bottom);
        } else {
            // Normal views are simply positioned at the current offset
            CGRect frame = subview.frame;
            frame.origin.y = yOffsetOfCurrentSubview;
            frame.size.width = self.bounds.size.width;
            subview.frame = frame;
            
            yOffsetOfCurrentSubview += frame.size.height;
        }
    }
    
    // If our content is shorter than our bounds height, take the contentInset into account to avoid
    // scrolling when it is not needed.
    CGFloat minimumContentHeight = self.bounds.size.height - (self.contentInset.top + self.contentInset.bottom);
    self.contentSize = CGSizeMake(self.bounds.size.width, fmax(yOffsetOfCurrentSubview, minimumContentHeight));
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == KVOContext) {
        // Initiate a layout recalculation only when a subviewʼs frame or contentSize has changed
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            UIScrollView *scrollView = object;
            CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = scrollView.contentSize;
            if (!CGSizeEqualToSize(newContentSize, oldContentSize)) {
                [self setNeedsLayout];
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))] ||
                   [keyPath isEqualToString:NSStringFromSelector(@selector(bounds))]) {
            UIView *subview = object;
            CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect newFrame = subview.frame;
            if (!CGRectEqualToRect(newFrame, oldFrame)) {
                [self setNeedsLayout];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
