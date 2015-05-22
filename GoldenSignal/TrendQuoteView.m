//
//  TrendQuoteView.m
//  CBNAPP
//
//  Created by Frank on 14/12/18.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "TrendQuoteView.h"
#import "PPiFlatSegmentedControl.h"

@implementation TrendQuoteView
{
    NSString *_code;
    NSUInteger _selectedTabIndex;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, CGRectGetHeight(frame))];
        [self addSubview:_mainView];
        
        _sideView = [[UIView alloc] initWithFrame:CGRectMake(222, 18, 98, CGRectGetHeight(frame) - 18)];
        [self addSubview:_sideView];
        
        PPiFlatSegmentedControl *segmented = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(222, 0, 98, 18) items:@[@{@"text":@"五档"}, @{@"text":@"明细"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
            _selectedTabIndex = segmentIndex;
            [self loadSideView];
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
    for (UIView *sub in _mainView.subviews) {
        [sub removeFromSuperview];
    }
    switch (type) {
        case TRENDLINE_1:
            if (_oneDayLine == nil) {
                _oneDayLine = [[TrendLineView alloc] initWithFrame:_mainView.bounds andCode:_code];
                [_oneDayLine loadTrendLineDataWithNumberOfDays:1];
            }
            [_mainView addSubview:_oneDayLine];
            break;
        case TRENDLINE_5:
            if (_fiveDaysLine == nil) {
                _fiveDaysLine = [[TrendLineView alloc] initWithFrame:_mainView.bounds andCode:_code];
                [_fiveDaysLine loadTrendLineDataWithNumberOfDays:5];
            }
            [_mainView addSubview:_fiveDaysLine];
            break;
    }
}

- (void)loadSideView {
    for (UIView *sub in _sideView.subviews) {
        [sub removeFromSuperview];
    }
    switch (_selectedTabIndex) {
        case 0:
            if (_fiveBets == nil) {
                _fiveBets = [[FiveBetsView alloc] initWithFrame:_sideView.bounds andCode:_code];
            }
            [_sideView addSubview:_fiveBets];
            break;
        case 1:
            if (_subDeal == nil) {
                _subDeal = [[SubDealView alloc] initWithFrame:_sideView.bounds andCode:_code];
            }
            [_sideView addSubview:_subDeal];
            break;
    }
}

// 订阅分时和报价
- (void)subscribeTrendLineAndQuoteWithType:(TrendLineType)type {
    [self loadMainViewWithType:type];
    [self loadSideView];
}

@end
