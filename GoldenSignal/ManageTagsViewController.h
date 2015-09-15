//
//  ManageTagsViewController.h
//  CBNAPP
//
//  Created by Frank on 14-10-14.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageTagsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic,strong) IBOutlet UICollectionView *collectionView;

@end


/**
 *  标签单元格
 */
@interface TagCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UILabel *textLabel;

@property(nonatomic, strong) BDNewsTag *newsTag;

@end