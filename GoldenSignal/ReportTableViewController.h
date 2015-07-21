//
//  ReportTableViewController.h
//  GoldenSignal
//
//  Created by CBD on 6/23/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PushBlock)(NSObject *obj);

@interface ReportTableViewController : UITableViewController



@property (nonatomic, copy) NSString *codeId;

@property (nonatomic,assign) int pageNumbs;


@property (nonatomic,copy) PushBlock pushAction1;

@end
