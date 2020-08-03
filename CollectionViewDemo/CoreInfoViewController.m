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

@protocol Person <NSObject>

- (NSString *)name;

- (NSUInteger )age;

- (void)speak;

@end

@interface CoreInfoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *titles;

@property (nonatomic, strong) void (^blcok)(void);

@property (nonatomic, weak) id <Person>delegate;

@end

@class Son;



@interface Person : NSObject<Person>

@property (nonatomic, strong) Son *son;

@end

@implementation Person

- (void)dealloc {
    NSLog(@"Person dealloc");
}

@end

@interface Son : NSObject <Person>

@property (nonatomic, strong) Person *person;

@end

@implementation Son

- (void)dealloc {
    NSLog(@"Son dealloc");
}

- (NSString *)name {
    return @"son";
}

- (void)speak {
    NSLog(@"lala");
}

@end

@implementation CoreInfoViewController

- (void)dealloc {
    NSLog(@"CoreInfoViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    Person *p = [[Person alloc] init];
    Son *son = [[Son alloc] init];
    self.delegate = son;
//    p.son = s;
//    s.person = p;
    if ([son conformsToProtocol:@protocol(Person)]) {
        [son name];
        [son speak];
//        [son age];
        if ([son respondsToSelector:@selector(age)]) {
            [son age];
        }
    }
    self.title = NSLocalizedString(@"Core Info", nil);
    
    __weak typeof(self) weakSelf = self;
    [self setBlcok:^{
        weakSelf.title = @"test";
    }];
    self.blcok();

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
    NSArray *datas = @[
        @[@"均价",@"1000元每平"],
        @[@"建面",@"88M2"],
        @[@"朝向",@"南"],
        @[@"分布",@"那北通透"],
        @[@"描述",@"分别表示了二手房，小区，楼盘，租房不同的房源性质；4个类型中存在组件的共用，包括顶部、底部视图的功能。\n初始化方法内首先通过TTRoute传值，传递了必要的参数，同时不同的path也是对缺省参数的一个兼容。"],
        @[@"均价",@"1000元每平"],
        @[@"建面",@"88M2"],
        @[@"朝向",@"南"],
        @[@"分布",@"那北通透"],
        @[@"描述",@"分别表示了二手房，小区，楼盘，租房不同的房源性质；4个类型中存在组件的共用，包括顶部、底部视图的功能。\n初始化方法内首先通过TTRoute传值，传递了必要的参数，同时不同的path也是对缺省参数的一个兼容。"],
        @[@"均价",@"1000元每平"],
        @[@"建面",@"88M2"],
        @[@"朝向",@"南"],
        @[@"分布",@"那北通透"],
        @[@"描述",@"分别表示了二手房，小区，楼盘，租房不同的房源性质；4个类型中存在组件的共用，包括顶部、底部视图的功能。\n初始化方法内首先通过TTRoute传值，传递了必要的参数，同时不同的path也是对缺省参数的一个兼容。"],
    ];
    for (int i = 0; i < datas.count; i++) {
        CoreInfoModel *infoModel = [[CoreInfoModel alloc] init];
        infoModel.title = [datas[i] objectAtIndex:0];
        infoModel.value = [datas[i] objectAtIndex:1];
//        NSString *title = [NSString stringWithFormat:@"index :%d",i];
//        infoModel.title = title;
//        if (random()%5 == i%5) {
//            infoModel.value = [title stringByAppendingString:@"dsfskjafldjsakjfldsjafljdscxkjkljkljsfkldsjalkfjklsdjfkjaslkfjadsklfdsaklf"];
//        }
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

- (void)callback {
    if ([self.delegate respondsToSelector:@selector(speak)]) {
        [self.delegate speak];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CoreInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CoreInfoCollectionViewCell class]) forIndexPath:indexPath];
    CoreInfoModel *infoModel = self.titles[indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",infoModel.title,infoModel.value];
//    cell.titleLabel.text = [NSString stringWithFormat:@"index :%d",indexPath.row];
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(CGRectGetWidth(collectionView.frame)/2.0);
    CoreInfoModel *infoModel = self.titles[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@:%@",infoModel.title,infoModel.value];
    CGRect frame = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
    if (frame.size.width > width) {
        width = CGRectGetWidth(collectionView.frame);
        
        frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
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
