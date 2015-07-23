//
//  SecuNewsListView.h
//  GoldenSignal
//
//  Created by Frank on 15/7/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SecuNewsListViewDelegate <NSObject>

-(void)didSelectNews:(BDSecuNews *)news;

@end

@interface SecuNewsListView : UITableViewController

@property(nonatomic, weak) id <SecuNewsListViewDelegate> delegate;
@property(nonatomic, strong) NSString *secuCode;

@end
