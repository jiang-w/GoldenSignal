//
//  PortfolioMainViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/7/21.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleTabViewController.h"
#import "NewsEventListViewController.h"
#import "StockPoolViewController.h"

@interface PortfolioMainViewController : UIViewController<UIScrollViewDelegate, TitleTabViewDelegate, NewsEventListViewDelegate>

@end
