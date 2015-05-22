//
//  TitleTabViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TitleTabViewDelegate <NSObject>

- (void)didChangedTabIndex:(NSInteger)index;

@end

@interface TitleTabViewController : UICollectionViewController

@property(nonatomic, readonly) NSInteger selectedIndex;
@property(nonatomic, retain) NSArray *tabArray;
@property(nonatomic, strong) id<TitleTabViewDelegate> delegate;

- (void)changeSelectedIndex:(NSInteger)index;

@end


#pragma mark - Cell

@interface TitleTabCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UILabel *textLabel;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *code;

@end