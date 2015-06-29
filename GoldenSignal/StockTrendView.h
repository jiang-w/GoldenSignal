//
//  TrendQuoteView.h
//  CBNAPP
//
//  Created by Frank on 14/12/18.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendLineChart.h"
#import "FiveBetsView.h"
#import "SubDealView.h"

@interface StockTrendView : UIView

@property(nonatomic, strong) NSString *code;

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code;

- (void)subscribeTrendLineAndQuoteWithType:(TrendLineType)type;

@end
