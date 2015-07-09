//
//  RankingListViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/7/9.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingListViewController : UITableViewController

- (void)loadDataWithSectId:(NSUInteger)id andNumber:(NSUInteger)number orderByDesc:(BOOL)desc;

@end
