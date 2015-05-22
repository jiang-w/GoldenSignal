//
//  SectCollectionViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/2/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SectCollectionViewController.h"
#import "SectCollectionViewModel.h"
#import "SectQuoteViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface SectCollectionViewController ()
{
    SectCollectionViewModel *_vm;
    dispatch_queue_t loadDataQueue;
}
@end

@implementation SectCollectionViewController

static NSString * const reuseIdentifier = @"SectTabCell";
static NSString * const headerIdentifier = @"HeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[SectCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];

    loadDataQueue = dispatch_queue_create("loadData", nil);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中...";
    dispatch_async(loadDataQueue, ^{
        _vm = [[SectCollectionViewModel alloc] init];
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_vm getNumberOfSections];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_vm getNumberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    BDSectInfo *sect = [_vm getSectInfoAtIndexPath:indexPath];
    cell.textLabel.text = sect.name;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * reusableview = nil ;
    
    if ( kind == UICollectionElementKindSectionHeader ) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = RGB(0, 98, 132, 1);
        NSString *title = [_vm getTitleForSection:indexPath.section];
        if (headerView.subviews.count > 0) {
            UILabel *label = [headerView.subviews firstObject];
            label.text = title;
        }
        else {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, CGRectGetHeight(headerView.frame))];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:12];
            label.text = title;
            [headerView addSubview:label];
        }
        
        reusableview = headerView;
    }
    return reusableview;
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BDSectInfo *sect = [_vm getSectInfoAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSectInfo:)]) {
        [self.delegate didSelectSectInfo:sect];
    }
}

@end


#pragma mark - Cell

@implementation SectCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectZero];
        [background setImage:[UIImage imageNamed:@"label_0"]];
        self.backgroundView = background;
        
        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:11];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
    }
    return self;
}

@end

