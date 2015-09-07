//
//  FinanceViewController.h
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCColor.h"
#define chartMargin     10
#define xLabelMargin    15
#define yLabelMargin    15
#define UULabelHeight   10
#define UUYLabelwidth   30

@interface FinanceViewController : UIViewController

@property(nonatomic, strong) NSString *BD_CODE;

@property (nonatomic,strong) UIView *baseView;

@property (strong, nonatomic) NSArray * yLabels;
@property (nonatomic) float yValueMax;
@property (nonatomic) float yValueMin;

@property (nonatomic, assign) BOOL showRange;

@property (nonatomic, assign) CGRange chooseRange;

@end
