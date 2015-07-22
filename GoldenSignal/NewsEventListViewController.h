//
//  NewsListViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsEventListViewDelegate <NSObject>

-(void)didSelectNewsEvent:(BDNewsEvent *)newsEvent;

@end

@interface NewsEventListViewController : UITableViewController

@property(nonatomic, assign) id <NewsEventListViewDelegate> delegate;

- (id)initWithTagId:(NSNumber *)tagId andSecuCodes:(NSArray *)codes;

@end
