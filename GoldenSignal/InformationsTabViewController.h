//
//  TestTableViewController.h
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/16/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationsTabViewController : UITableViewController


- (id)initWithCodeId:(NSString *)codeId;

@property (nonatomic, copy) NSString *InformationId;

@property (nonatomic,assign) int pageNumbs;

@end
