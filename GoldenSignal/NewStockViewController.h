//
//  NewStockTableViewController.h
//  GoldenSignal
//
//  Created by CBD on 7/8/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewStockViewController : UIViewController


- (instancetype)initWithPageId:(int)pageId;

@property (nonatomic,assign) int pageNumbs;//每页数量

@end
