//
//  ManageTagsViewController.m
//  CBNAPP
//
//  Created by Frank on 14-10-14.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "ManageTagsViewController.h"
#import "CustomTagsViewModel.h"

@interface ManageTagsViewController ()

@end

@implementation ManageTagsViewController
{
    NSArray *_customNewsTags;
}

static NSString * const reuseIdentifier = @"TagCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BDCustomTagCollection *tagCollection = [BDCustomTagCollection sharedInstance];
    _customNewsTags = tagCollection.tags;
    // 接收用户定制标签更改的通知
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(customTagsChangedHandler) name:TAGS_CHANGED_NOTIFICATION object:nil];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)customTagsChangedHandler {
    BDCustomTagCollection *tagCollection = [BDCustomTagCollection sharedInstance];
    _customNewsTags = tagCollection.tags;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _customNewsTags.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row >= _customNewsTags.count) {
        cell.tag = nil;
        // 为cell添加单击手势识别器
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCustomLabel:)];
        [cell addGestureRecognizer:singleTap];
    }
    else {
        cell.tag = _customNewsTags[indexPath.row];
        //拖动手势
        UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragCustomLabel:)];
        [cell addGestureRecognizer:drag];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark

// 单击定制标签触发
- (void)singleCustomLabel:(UITapGestureRecognizer *)sender
{
    [self performSegueWithIdentifier:@"showCustomTag" sender:nil];
}


CGRect originalFrame;
// 拖拽定制标签触发
-(void)dragCustomLabel:(UIPanGestureRecognizer*)sender {
    TagCollectionViewCell *dragView = (TagCollectionViewCell *)sender.view;
    TagCollectionViewCell *tragetView = nil;
    
    //获取手势在该视图上得偏移量
    CGPoint translation = [sender translationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        //开始时拖动的view更改透明度
        dragView.alpha = 0.5;
        [dragView.superview bringSubviewToFront:dragView];
        originalFrame = dragView.frame;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        //使拖动的view跟随手势移动
        dragView.center = CGPointMake(dragView.center.x + translation.x, dragView.center.y + translation.y);
        [sender setTranslation:CGPointZero inView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        for (TagCollectionViewCell *cell in self.collectionView.visibleCells) {
            if (dragView != cell && cell.tag != nil && CGRectContainsPoint(cell.frame, dragView.center)) {
                tragetView = cell;
                break;
            }
        }
        if (tragetView) {
            // 交换的两个view的frame
            [UIView animateWithDuration:0.3 animations:^{
                dragView.frame = tragetView.frame;
                tragetView.frame = originalFrame;
                dragView.alpha = 1;
            } completion:^(BOOL finished) {
                NSUInteger index1 = [_customNewsTags indexOfObject:dragView.tag];
                NSUInteger index2 = [_customNewsTags indexOfObject:tragetView.tag];
                [[BDCustomTagCollection sharedInstance] exchangeTagAtIndex:index1 withTagAtIndex:index2];
            }];
        }
        else {
            // 回到原始位置
            [UIView animateWithDuration:0.3 animations:^{
                dragView.frame = originalFrame;
                dragView.alpha = 1;
            }];
        }
    }
}

@end


#pragma mark - TagCollectionViewCell

@implementation TagCollectionViewCell

@synthesize tag;

- (void)setTag:(BDNewsTag *)value {
    tag = value;
    if (tag) {
        self.textLabel.text = tag.name;
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectZero];
        [background setImage:[UIImage imageNamed:@"label_0"]];
        self.backgroundView = background;
    }
    else {
        self.textLabel.text = @"";
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectZero];
        [background setImage:[UIImage imageNamed:@"label_3"]];
        self.backgroundView = background;
    }
}

@end
