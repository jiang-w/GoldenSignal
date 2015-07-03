//
//  IdxDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxDetailViewController.h"
#import "IdxQuoteView.h"
#import "TrendLineChart.h"
#import <Masonry.h>
#import <PPiFlatSegmentedControl.h>

@interface IdxDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;

@property(nonatomic, strong) IdxQuoteView *idxQuoteView;
@property(nonatomic, strong) PPiFlatSegmentedControl *chartTabView;
@property(nonatomic, strong) TrendLineChart *oneDayTrendLine;
@property(nonatomic, strong) TrendLineChart *fiveDayTrendLine;

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
    self.idxQuoteView = [IdxQuoteView createView];
    [self addSubView:self.idxQuoteView withHeight:110 andSpace:0];
    
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

// 加载分时、K线视图
- (void)loadChartView {
    for (UIView *sub in self.chartContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_chartTabIndex) {
        case 0: {
            if (self.oneDayTrendLine == nil) {
                self.oneDayTrendLine = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.oneDayTrendLine.margin = 1;
                [self.oneDayTrendLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.oneDayTrendLine];
            break;
        }
        case 1: {
            if (self.fiveDayTrendLine == nil) {
                self.fiveDayTrendLine = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.fiveDayTrendLine.margin = 1;
                self.fiveDayTrendLine.days = 5;
                [self.fiveDayTrendLine loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.fiveDayTrendLine];
            break;
        }

        default:break;
    }
}

- (void)loadData {
    if (self.idxCode) {
        [self.idxQuoteView loadDataWithIdxCode:self.idxCode];
        [self loadChartView];
    }
}

- (void)dealloc {
    NSLog(@"IdxDetailViewController dealloc");
}

@end
