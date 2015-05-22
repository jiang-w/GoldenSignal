//
//  SectCollectionViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectCollectionViewDelegate <NSObject>

- (void)didSelectSectInfo:(BDSectInfo *)info;

@end

@interface SectCollectionViewController : UICollectionViewController

@property(nonatomic, assign) id <SectCollectionViewDelegate> delegate;

@end


@interface SectCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong)UILabel *textLabel;

@end