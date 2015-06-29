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

@interface TrendQuoteView : UIView
{
    UIView *_mainView;
    UIView *_sideView;
    
    TrendLineChart *_oneDayLine;
    TrendLineChart *_fiveDaysLine;
    FiveBetsView *_fiveBets;
    SubDealView *_subDeal;
}

@property(nonatomic, strong, readonly)NSString *code;

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code;

- (void)subscribeTrendLineAndQuoteWithType:(TrendLineType)type;

@end
