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
#import "BDSectService.h"

#import <Masonry.h>
#import <PPiFlatSegmentedControl.h>

@interface IdxDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) IdxScalarView *scalarView;
@property(nonatomic, strong) PPiFlatSegmentedControl *chartTabView;
// 分时图
@property(nonatomic, strong) TrendLineChart *oneDayTrendLine;
@property(nonatomic, strong) TrendLineChart *fiveDayTrendLine;
// K线图
@property(nonatomic, strong) KLineChart *dailyKLine;
@property(nonatomic, strong) KLineChart *weeklyKLine;
@property(nonatomic, strong) KLineChart *monthlyKLine;

@property(nonatomic, strong) PPiFlatSegmentedControl *infoTabView;

@property(nonatomic, assign) NSInteger chartSelectIndex;
@property(nonatomic, assign) NSInteger infoSelectIndex;

@end

@implementation IdxDetailViewController
{
    BDSecuCode *_secu;
}

- (instancetype)initWithIdxCode:(NSString *)idxCode {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:idxCode];
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
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.navigationItem.titleView = self.titleLabel;

    /* 添加指数标价 */
    self.scalarView = [IdxScalarView createView];
    [self addSubView:self.scalarView withHeight:110 andSpace:0];
    
    __weak IdxDetailViewController *weakSelf = self;    // 解决block循环引用的问题
    /* 行情走势图Tab */
    self.chartTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"分时"}, @{@"text":@"五日"}, @{@"text":@"日K"}, @{@"text":@"周K"}, @{@"text":@"月K"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        weakSelf.chartSelectIndex = segmentIndex;
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

    /* 资讯Tab */
    self.infoTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"领涨股"}, @{@"text":@"领跌股"}, @{@"text":@"资金"}, @{@"text":@"新闻"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        }];
    self.infoTabView.color = RGB(7, 9, 8, 1);
    self.infoTabView.borderWidth = 1;
    self.infoTabView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
    self.infoTabView.selectedColor = RGB(30, 30, 30, 1);
    self.infoTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214, 1)};
    self.infoTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
    [self addSubView:self.infoTabView withHeight:30 andSpace:2];
    
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
    if (_secu) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", _secu.name, _secu.trdCode];
        [self.titleLabel sizeToFit];
        [self.scalarView loadDataWithIdxCode:_secu.bdCode];
        [self loadChartView];
        
        dispatch_async(dispatch_queue_create("loadData", nil), ^{
            BDSectService *service = [[BDSectService alloc] init];
            NSUInteger sectId = [service getSectIdByIndexCode:_secu.bdCode];
            NSLog(@"指数(%@)所属板块%lu", _secu.bdCode, sectId);
        });
    }
}

// 加载分时、K线视图
- (void)loadChartView {
    for (UIView *sub in self.chartContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_chartSelectIndex) {
        case 0: {
            if (self.oneDayTrendLine == nil) {
                self.oneDayTrendLine = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                [self.oneDayTrendLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.oneDayTrendLine];
            break;
        }
        case 1: {
            if (self.fiveDayTrendLine == nil) {
                self.fiveDayTrendLine = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.fiveDayTrendLine.days = 5;
                [self.fiveDayTrendLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.fiveDayTrendLine];
            break;
        }
        case 2: {
            if (self.dailyKLine == nil) {
                self.dailyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.dailyKLine.number = 60;
                [self.dailyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.dailyKLine];
            break;
        }
        case 3: {
            if (self.weeklyKLine == nil) {
                self.weeklyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.weeklyKLine.type = KLINE_WEEK;
                self.weeklyKLine.number = 60;
                [self.weeklyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.weeklyKLine];
            break;
        }
        case 4: {
            if (self.monthlyKLine == nil) {
                self.monthlyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.monthlyKLine.type = KLINE_MONTH;
                self.monthlyKLine.number = 60;
                [self.monthlyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.monthlyKLine];
            break;
        }

        default:break;
    }
}


#pragma mark Dealloc

- (void)dealloc {
    NSLog(@"IdxDetailViewController dealloc (%@)", _secu.bdCode);
}

@end
