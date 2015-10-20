//
//  TitleTabViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/2/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TitleTabViewController.h"

@interface TitleTabViewController ()
{
    NSString *_selectedCode;
}

@end

@implementation TitleTabViewController

static NSString * const reuseIdentifier = @"TitleTabCell";

- (void)setTabArray:(NSArray *)tabArray {
    _tabArray = tabArray;
    _selectedIndex = -1;
    [self.collectionView reloadData];
    
    for (int i = 0; i < _tabArray.count; i++) {
        NSString *code = [[_tabArray[i] allKeys] firstObject];
        if ([code isEqualToString:_selectedCode]) {
            [self changeSelectedIndex:i];
            return;
        }
    }
    [self changeSelectedIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
//    [self.collectionView registerClass:[TitleTabCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Register cell with nib
    [self.collectionView registerNib:[UINib nibWithNibName:@"TitleTabViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.allowsMultipleSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeSelectedIndex:(NSInteger)index {
    if (index >= 0 && index < _tabArray.count && index != _selectedIndex) {
        _selectedIndex = index;
        _selectedCode = [[[_tabArray objectAtIndex:index] allKeys] firstObject];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangedTabIndex:)]) {
            [self.delegate didChangedTabIndex:index];
        }
        
        // 设置collectionView选中样式
        NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *path in indexPaths) {
            TitleTabCell *cell = (TitleTabCell *)[self.collectionView cellForItemAtIndexPath:path];
            [self removeSelectedStyleForCell:cell];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        [self.collectionView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        TitleTabCell *selectedCell = (TitleTabCell *)[self.collectionView cellForItemAtIndexPath:path];
        [self setSelectedStyleForCell:selectedCell];
    }
}

- (void)setSelectedStyleForCell:(TitleTabCell *)cell {
    cell.textLabel.textColor = [UIColor redColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
}

- (void)removeSelectedStyleForCell:(TitleTabCell *)cell {
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tabArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TitleTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSDictionary *item = [self.tabArray objectAtIndex:indexPath.row];
    NSString *name = item.allValues.firstObject;
    NSString *code = item.allKeys.firstObject;
    cell.title = name;
    cell.code = code;
    if (indexPath.row == _selectedIndex) {
        [self setSelectedStyleForCell:cell];
    }
    else {
        [self removeSelectedStyleForCell:cell];
    }
    return cell;
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self changeSelectedIndex:indexPath.row];
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.tabArray objectAtIndex:indexPath.row];
    NSString *name = item.allValues.firstObject;
    CGSize fontSize = [name sizeWithFont:[UIFont boldSystemFontOfSize:16] maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGSize cellSize = CGSizeMake(fontSize.width + 20, 30);
    return cellSize;
}

//定义每个UICollectionView 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(5, 16, 5, 16);
//}

@end


#pragma mark - Cell

@implementation TitleTabCell

//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
//        self.textLabel.font = [UIFont systemFontOfSize:12];
//        self.textLabel.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:self.textLabel];
//    }
//    return self;
//}

- (void)setTitle:(NSString *)title {
    if (self.textLabel) {
        self.textLabel.text = title;
    }
}

@end
