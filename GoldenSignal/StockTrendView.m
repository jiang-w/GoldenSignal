//
//  TrendQuoteView.m
//  CBNAPP
//
//  Created by Frank on 14/12/18.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StockTrendView.h"
#import "TrendLineChart.h"
#import "FiveBetsView.h"
#import "SubDealView.h"
#import "PPiFlatSegmentedControl.h"

@interface StockTrendView()

@property(nonatomic, strong) UIView *mainView;
@property(nonatomic, strong) UIView *sideView;

@property(nonatomic, strong) TrendLineChart *oneDayLine;
@property(nonatomic, strong) TrendLineChart *fiveDaysLine;
@property(nonatomic, strong) FiveBetsView *fiveBets;
@property(nonatomic, strong) SubDealView *subDeal;

@property(nonatomic, assign) NSUInteger selectedTabIndex;

@end

@implementation StockTrendView

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, CGRectGetHeight(frame))];
        [self addSubview:self.mainView];
        
        self.sideView = [[UIView alloc] initWithFrame:CGRectMake(222, 18, 98, CGRectGetHeight(frame) - 18)];
        [self addSubview:self.sideView];
        
        __weak StockTrendView *weakSelf = self;    // 解决block循环引用的问题
        PPiFlatSegmentedControl *segmented = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(222, 0, 98, 18) items:@[@{@"text":@"五档"}, @{@"text":@"明细"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
            weakSelf.selectedTabIndex = segmentIndex;
            [weakSelf loadSideView];
        }];
        segmented.color = RGB(7, 9, 8, 1);
        segmented.borderWidth = 1;
        segmented.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
        segmented.selectedColor = RGB(30, 30, 30, 1);
        segmented.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSForegroundColorAttributeName:[UIColor whiteColor]};
        segmented.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
        [self addSubview:segmented];
        
        if (code) {
            _code = [code copy];
        }
    }
    return self;
}

- (void)loadMainViewWithType:(TrendLineType)type {
    for (UIView *sub in self.mainView.subviews) {
        [sub removeFromSuperview];
    }
    switch (type) {
        case TRENDLINE_1:
            if (self.oneDayLine == nil) {
                self.oneDayLine = [[TrendLineChart alloc] initWithFrame:self.mainView.bounds];
                self.oneDayLine.days = 1;
                self.oneDayLine.margin = 2;
                self.oneDayLine.fillColor = RGB(225, 112, 35, 0.15);
                [self.oneDayLine loadDataWithSecuCode:_code];
            }
            [self.mainView addSubview:self.oneDayLine];
            break;
        case TRENDLINE_5:
            if (self.fiveDaysLine == nil) {
                self.fiveDaysLine = [[TrendLineChart alloc] initWithFrame:self.mainView.bounds];
                self.fiveDaysLine.days = 5;
                self.fiveDaysLine.margin = 2;
                self.fiveDaysLine.lineColor = [UIColor orangeColor];
                self.fiveDaysLine.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.15];
                [self.fiveDaysLine loadDataWithSecuCode:_code];
            }
            [self.mainView addSubview:self.fiveDaysLine];
            break;
    }
}

- (void)loadSideView {
    for (UIView *sub in self.sideView.subviews) {
        [sub removeFromSuperview];
    }
    switch (_selectedTabIndex) {
        case 0:
            if (self.fiveBets == nil) {
                self.fiveBets = [[FiveBetsView alloc] initWithFrame:self.sideView.bounds andCode:_code];
            }
            [self.sideView addSubview:self.fiveBets];
            break;
        case 1:
            if (self.subDeal == nil) {
                self.subDeal = [[SubDealView alloc] initWithFrame:self.sideView.bounds andCode:_code];
            }
            [self.sideView addSubview:self.subDeal];
            break;
    }
}

// 订阅分时和报价
- (void)subscribeTrendLineAndQuoteWithType:(TrendLineType)type {
    [self loadMainViewWithType:type];
    [self loadSideView];
}

@end
