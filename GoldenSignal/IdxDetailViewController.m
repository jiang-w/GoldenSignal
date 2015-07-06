//
//  IdxDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxDetailViewController.h"
#import "IdxScalarView.h"
#import "TrendLineChart.h"
#import "KLineChart.h"
#import <Masonry.h>
#import <PPiFlatSegmentedControl.h>

@interface IdxDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;

@property(nonatomic, strong) IdxScalarView *scalarView;
@property(nonatomic, strong) PPiFlatSegmentedControl *chartTabView;
// 分时图
@property(nonatomic, strong) TrendLineChart *oneDayTrendLine;
@property(nonatomic, strong) TrendLineChart *fiveDayTrendLine;
// K线图
@property(nonatomic, strong) KLineChart *dailyKLine;
@property(nonatomic, strong) KLineChart *weeklyKLine;
@property(nonatomic, strong) KLineChart *monthlyKLine;

@property(nonatomic, assign) NSInteger chartTabIndex;
@property(nonatomic, strong) NSString *idxCode;

@end

@implementation IdxDetailViewController

- (instancetype)initWithIdxCode:(NSString *)idxCode {
    self = [super init];
    if (self) {
        self.idxCode = idxCode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingView];
    [self loadData];
}

- (void)settingView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(self.view);
    }];
    
    self.containerView = [[UIView alloc] init];
    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    /* 添加指数标价 */
    self.scalarView = [IdxScalarView createView];
    [self addSubView:self.scalarView withHeight:110 andSpace:0];
    
    __weak IdxDetailViewController *weakSelf = self;    // 解决block循环引用的问题
    /* 行情走势图Tab */
    self.chartTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"分时"}, @{@"text":@"五日"}, @{@"text":@"日K"}, @{@"text":@"周K"}, @{@"text":@"月K"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        weakSelf.chartTabIndex = segmentIndex;
        [weakSelf loadChartView];
    }];
    self.chartTabView.color = RGB(7, 9, 8, 1);
    self.chartTabView.borderWidth = 1;
    self.chartTabView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
    self.chartTabView.selectedColor = RGB(30, 30, 30, 1);
    self.chartTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214, 1)};
    self.chartTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
    [self addSubView:self.chartTabView withHeight:30 andSpace:2];
    
    /* 分时、K线容器视图 */
    self.chartContainerView = [[UIView alloc] init];
    self.chartContainerView.backgroundColor = RGB(30, 30, 30, 1);
    [self addSubView:self.chartContainerView withHeight:180 andSpace:4];

    UIView *lastView = self.containerView.subviews.lastObject;
    if (lastView) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastView.mas_bottom);
        }];
    }
}

- (void)addSubView:(UIView *) subView withHeight:(CGFloat)height andSpace:(CGFloat)space {
    UIView *lastView = self.containerView.subviews.lastObject;
    if (subView) {
        [self.containerView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(space);
            }
            else {
                make.top.equalTo(self.containerView).with.offset(space);
            }
            make.left.and.right.equalTo(self.containerView);
            make.height.mas_equalTo(height);
        }];
    }
}


#pragma mark Load Data

- (void)loadData {
    if (self.idxCode) {
        [self.scalarView loadDataWithIdxCode:self.idxCode];
        [self loadChartView];
    }
}

// 加载分时、K线视图
- (void)loadChartView {
    for (UIView *sub in self.chartContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_chartTabIndex) {
        case 0: {
            if (self.oneDayTrendLine == nil) {
                self.oneDayTrendLine = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                [self.oneDayTrendLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.oneDayTrendLine];
            break;
        }
        case 1: {
            if (self.fiveDayTrendLine == nil) {
                self.fiveDayTrendLine = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.fiveDayTrendLine.days = 5;
                [self.fiveDayTrendLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.fiveDayTrendLine];
            break;
        }
        case 2: {
            if (self.dailyKLine == nil) {
                self.dailyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.dailyKLine.number = 60;
                [self.dailyKLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.dailyKLine];
            break;
        }
        case 3: {
            if (self.weeklyKLine == nil) {
                self.weeklyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.weeklyKLine.type = KLINE_WEEK;
                self.weeklyKLine.number = 60;
                [self.weeklyKLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.weeklyKLine];
            break;
        }
        case 4: {
            if (self.monthlyKLine == nil) {
                self.monthlyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.monthlyKLine.type = KLINE_MONTH;
                self.monthlyKLine.number = 60;
                [self.monthlyKLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.monthlyKLine];
            break;
        }

        default:break;
    }
}


#pragma mark Dealloc

- (void)dealloc {
    NSLog(@"IdxDetailViewController dealloc (%@)", self.idxCode);
}

@end
