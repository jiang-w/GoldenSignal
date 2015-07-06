//
//  StockViewController.h
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StkScalarView.h"
#import "FiveBetsView.h"
#import "SubDealView.h"
#import "StockTrendView.h"

#import <PPiFlatSegmentedControl.h>

@interface StkDetailViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    PPiFlatSegmentedControl *chartTabView;
    PPiFlatSegmentedControl *infoTabView;
    
    StkScalarView *indicatorsView;
    StockTrendView *trendQuoteView;
    
    UITableView *infoListView;
}

@property(nonatomic, strong)IBOutlet UILabel *name;
@property(nonatomic, strong)IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong)NSString *defaultCode;

- (void)subscribeQuotationWithCode:(NSString *)code;

@end
