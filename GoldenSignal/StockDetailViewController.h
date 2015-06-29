//
//  StockViewController.h
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorsView.h"
#import "TrendLineView.h"
#import "FiveBetsView.h"
#import "SubDealView.h"
#import "KLineView.h"
#import "StockTrendView.h"

#import <PPiFlatSegmentedControl.h>

@interface StockDetailViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIView *containerView;
    UIView *chartContainerView;
    UIView *infoContainerView;
    
    PPiFlatSegmentedControl *chartTabView;
    PPiFlatSegmentedControl *infoTabView;
    
    IndicatorsView *indicatorsView;
    StockTrendView *trendQuoteView;
    KLineView *dailyKLineView;
    KLineView *weeklyKLineView;
    KLineView *monthlyKLineView;
    
    UITableView *infoListView;
}

@property(nonatomic, strong)IBOutlet UILabel *name;
@property(nonatomic, strong)IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong)NSString *defaultCode;

- (void)subscribeQuotationWithCode:(NSString *)code;

@end
