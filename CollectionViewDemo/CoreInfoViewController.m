//
//  CoreInfoViewController.m
//  CollectionViewDemo
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "CoreInfoViewController.h"
#import "LeftAlignedCollectionViewFlowLayout.h"
#import "CoreInfoCollectionViewCell.h"
#import "CoreInfoModel.h"

@interface CoreInfoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *titles;

@end

@implementation CoreInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Core Info", nil);
    /**

     @property (nonatomic) CGFloat minimumLineSpacing;
     @property (nonatomic) CGFloat minimumInteritemSpacing;
     @property (nonatomic) CGSize itemSize;
     @property (nonatomic) CGSize estimatedItemSize API_AVAILABLE(ios(8.0)); // defaults to CGSizeZero - setting a non-zero size enables cells that self-size via -preferredLayoutAttributesFittingAttributes:
     @property (nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionVertical
     @property (nonatomic) CGSize headerReferenceSize;
     @property (nonatomic) CGSize footerReferenceSize;
     @property (nonatomic) UIEdgeInsets sectionInset;
     */
    
    NSMutableArray *titles = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        CoreInfoModel *infoModel = [[CoreInfoModel alloc] init];
        NSString *title = [NSString stringWithFormat:@"index :%d",i];
        infoModel.title = title;
        if (random()%5 == i%5) {
            infoModel.value = [title stringByAppendingString:@"dsfskjafldjsakjfldsjafljdscxkjkljkljsfkldsjalkfjklsdjfkjaslkfjadsklfdsaklf"];
        }
        [titles addObject:infoModel];
    }
    self.titles = titles.copy;
    
    
    CGFloat width = floor(CGRectGetWidth(self.view.bounds)/2.0);
    LeftAlignedCollectionViewFlowLayout *layout = [[LeftAlignedCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(width, 20);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[CoreInfoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CoreInfoCollectionViewCell class])];
//    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    self.collectionView.contentInset = UIEdgeInsetsMake(1000, 0, 0, 0);
//    self.collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CoreInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CoreInfoCollectionViewCell class]) forIndexPath:indexPath];
    CoreInfoModel *infoModel = self.titles[indexPath.row];
    cell.titleLabel.text = infoModel.value;
//    cell.titleLabel.text = [NSString stringWithFormat:@"index :%d",indexPath.row];
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(CGRectGetWidth(collectionView.frame)/2.0);
    CoreInfoModel *infoModel = self.titles[indexPath.row];
    CGRect frame = [infoModel.value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
    if (frame.size.width > width) {
        width = CGRectGetWidth(collectionView.frame);
        
        frame = [infoModel.value boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
        if (frame.size.height > 20) {
            return CGSizeMake(width, frame.size.height + 20);
        }
    }
//    CGFloat width = floor(/2);
    return CGSizeMake(width, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row % 2 == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"testForKey" object:nil];
//    } else {
//        NotificationViewController *notiVC = [[NotificationViewController alloc] init];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:notiVC];
//        nav.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:nav animated:YES completion:nil];
//    }
}
@end
