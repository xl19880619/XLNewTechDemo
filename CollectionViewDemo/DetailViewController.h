//
//  DetailViewController.h
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/21.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@end

@interface DetailItem : NSObject

@property (nonatomic, copy) NSString *sectionTitle;

@property (nonatomic, copy) NSString *itemValue;

@property (nonatomic) BOOL useShadow;
@property (nonatomic) BOOL containSection;

@property (nonatomic) BOOL isHeader;

@end

NS_ASSUME_NONNULL_END
