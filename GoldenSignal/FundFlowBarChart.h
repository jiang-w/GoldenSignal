//
//  FundFlowColumnChart.h
//  GoldenSignal
//
//  Created by Frank on 15/7/10.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FundFlowBarChart : UIView

// margin with bound
@property(nonatomic) CGFloat margin_top;
@property(nonatomic) CGFloat margin_left;
@property(nonatomic) CGFloat margin_bottom;
@property(nonatomic) CGFloat margin_right;

- (void)loadDataWithSecuCode:(NSString *)code;

@end
