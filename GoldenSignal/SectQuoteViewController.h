//
//  SectQuoteViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectQuoteViewDelegate <NSObject>

-(void)didSelectSecuCode:(NSString *)code;

@end


@interface SectQuoteViewController : UITableViewController

@property(nonatomic, assign) id <SectQuoteViewDelegate> delegate;

- (id)initWithSectId:(long)sectId;

@end
