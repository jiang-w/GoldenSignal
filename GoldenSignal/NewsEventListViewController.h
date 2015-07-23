//
//  NewsListViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsEventListViewDelegate <NSObject>

-(void)didSelectNewsEvent:(BDNewsEventList *)newsEvent;

@end

@interface NewsEventListViewController : UITableViewController

@property(nonatomic, weak) id <NewsEventListViewDelegate> delegate;

- (id)initWithTagId:(NSNumber *)tagId andSecuCodes:(NSArray *)codes;

@end
