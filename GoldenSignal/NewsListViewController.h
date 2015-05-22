//
//  NewsListViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsListViewDelegate <NSObject>

-(void)didSelectNews:(BDNews *)news;

@end

@interface NewsListViewController : UITableViewController

@property(nonatomic, assign) id <NewsListViewDelegate> delegate;

- (id)initWithTagId:(long)tagId;

@end
