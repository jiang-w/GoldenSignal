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
#import "RankingListViewController.h"
#import "KLineViewModel.h"

#import "FundFlowCircleChart.h"
#import "FundFlowBarView.h"

#import <Masonry.h>
#import <PPiFlatSegmentedControl.h>

@interface IdxDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;
@property(nonatomic, strong) UIView *infoContainerView;
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

@property(nonatomic, strong) RankingListViewController *rankingList;
@property(nonatomic, strong) SecuNewsListView *newsListView;
@property(nonatomic, strong) FundFlowBarView *fundFlowBarView;

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
    self.scrollView.bounces = NO;
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
    [self addSubView:self.scalarView inView:self.containerView withHeight:110 andSpace:0];
    
    __weak IdxDetailViewController *weakSelf = self;    // 解决block循环引用的问题
    /* 行情走势图Tab */
    self.chartTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"分时"}, @{@"text":@"五日"}, @{@"text":@"日K"}, @{@"text":@"周K"}, @{@"text":@"月K"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        weakSelf.chartSelectIndex = segmentIndex;
        [weakSelf loadChartView];
    }];
    self.chartTabView.color = RGB(7, 9, 8);
    self.chartTabView.borderWidth = 1;
    self.chartTabView.borderColor = RGB(80, 80, 80);
    self.chartTabView.selectedColor = RGB(30, 30, 30);
    self.chartTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214)};
    self.chartTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1)};
    [self addSubView:self.chartTabView inView:self.containerView withHeight:30 andSpace:2];
    
    /* 分时、K线容器视图 */
    self.chartContainerView = [[UIView alloc] init];
    self.chartContainerView.backgroundColor = RGB(30, 30, 30);
    [self addSubView:self.chartContainerView inView:self.containerView withHeight:180 andSpace:2];

    /* 资讯Tab */
    self.infoTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"领涨股"}, @{@"text":@"领跌股"}, @{@"text":@"资金"}, @{@"text":@"新闻"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        weakSelf.infoSelectIndex = segmentIndex;
        [weakSelf loadRankingList];
        
        // 点击Tab后scrollView滚动到其位置
        CGFloat scrollHeight = weakSelf.scrollView.frame.size.height;
        CGFloat contentHeight = weakSelf.scrollView.contentSize.height;
        CGFloat tabViewY = weakSelf.infoTabView.frame.origin.y - 64;
        CGFloat offsetY = tabViewY + scrollHeight > contentHeight ? contentHeight - scrollHeight : tabViewY;
        if (offsetY >= 0) {
            [weakSelf.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        }

    }];
    self.infoTabView.color = RGB(7, 9, 8);
    self.infoTabView.borderWidth = 1;
    self.infoTabView.borderColor = RGB(80, 80, 80);
    self.infoTabView.selectedColor = RGB(30, 30, 30);
    self.infoTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214)};
    self.infoTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1)};
    [self addSubView:self.infoTabView inView:self.containerView withHeight:30 andSpace:2];
    
    self.infoContainerView = [[UIView alloc] init];
    self.infoContainerView.backgroundColor = [UIColor clearColor];
    [self addSubView:self.infoContainerView inView:self.containerView withHeight:0 andSpace:2];
    
    UIView *lastView = self.containerView.subviews.lastObject;
    if (lastView) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastView);
        }];
    }
}

- (void)addSubView:(UIView *)subView inView:(UIView *)superView withHeight:(CGFloat)height andSpace:(CGFloat)space {
    UIView *lastView = superView.subviews.lastObject;
    if (subView) {
        [superView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).offset(space);
            }
            else {
                make.top.equalTo(superView);
            }
            make.left.and.right.equalTo(superView);
            make.height.mas_equalTo(height);
        }];
    }
}


#pragma mark Load Data

- (void)loadData {
    if (_secu) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", _secu.name, _secu.trdCode];
        [self.titleLabel sizeToFit];
        [self.scalarView subscribeDataWithSecuCode:_secu.bdCode];
        [self loadChartView];
        [self loadRankingList];
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
                self.weeklyKLine.number = 60;
                self.monthlyKLine.type = KLINE_WEEK;
                [self.weeklyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.weeklyKLine];
            break;
        }
        case 4: {
            if (self.monthlyKLine == nil) {
                self.monthlyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.monthlyKLine.number = 60;
                self.monthlyKLine.type = KLINE_MONTH;
                [self.monthlyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.monthlyKLine];
            break;
        }

        default:break;
    }
}

- (void)loadRankingList {
    for (UIView *sub in self.infoContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_infoSelectIndex) {
        case 0: {
            if (self.rankingList == nil) {
                self.rankingList = [[RankingListViewController alloc] init];
            }
            [self.infoContainerView addSubview:self.rankingList.tableView];
            [self.rankingList.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.infoContainerView);
            }];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                BDSectService *service = [[BDSectService alloc] init];
                NSUInteger sectId = [service getSectIdByIndexCode:_secu.bdCode];
                NSUInteger number = 10;
                [self.rankingList loadDataWithSectId:sectId andNumber:number orderByDesc:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.rankingList.tableView reloadData];
                    [self.infoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(self.rankingList.tableView.rowHeight * number);
                    }];
                });
            });
            break;
        }
        case 1: {
            if (self.rankingList == nil) {
                self.rankingList = [[RankingListViewController alloc] init];
            }
            [self.infoContainerView addSubview:self.rankingList.tableView];
            [self.rankingList.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.infoContainerView);
            }];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                BDSectService *service = [[BDSectService alloc] init];
                NSUInteger sectId = [service getSectIdByIndexCode:_secu.bdCode];
                NSUInteger number = 10;
                [self.rankingList loadDataWithSectId:sectId andNumber:number orderByDesc:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.rankingList.tableView reloadData];
                    [self.infoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(self.rankingList.tableView.rowHeight * number);
                    }];
                });
            });
            break;
        }
        case 2: {
            if (self.fundFlowBarView == nil) {
                self.fundFlowBarView = [[FundFlowBarView alloc] initWithNibName:@"FundFlowBarView" bundle:nil];
                self.fundFlowBarView.code = _secu.bdCode;
            }
            [self.infoContainerView addSubview:self.fundFlowBarView.view];
            [self.infoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.fundFlowBarView.view.frame.size.height);
            }];
            [self.fundFlowBarView.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.infoContainerView);
            }];
            
            break;
        }
        case 3: {
            if (self.newsListView == nil) {
                self.newsListView = [[SecuNewsListView alloc] init];
                self.newsListView.secuCode = _secu.bdCode;
                self.newsListView.type = NWS;
            }
            [self.infoContainerView addSubview:self.newsListView.view];
            [self.infoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.newsListView.tableView.rowHeight * 5);
            }];
            [self.newsListView.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.infoContainerView);
            }];
            break;
        }
    }
    
    [self.scrollView layoutIfNeeded];
}


#pragma mark Dealloc

- (void)dealloc {
    NSLog(@"IdxDetailViewController dealloc (%@)", _secu.bdCode);
}

@end
