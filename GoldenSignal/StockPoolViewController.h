//
//  CustomStockViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StockPoolViewDelegate <NSObject>

- (void)didSelectRowSecu:(NSString *)secuCode;

@end

@interface StockPoolViewController : UITableViewController<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <StockPoolViewDelegate> delegate;

@end
