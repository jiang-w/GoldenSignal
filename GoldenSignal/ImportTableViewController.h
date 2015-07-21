//
//  ImportTableViewController.h
//  GoldenSignal
//
//  Created by CBD on 7/6/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ImportTableViewController : UITableViewController

- (instancetype)initWithPageId:(int)pageId;


@property (nonatomic,assign) int pageNumbs;//每页数量

@end
