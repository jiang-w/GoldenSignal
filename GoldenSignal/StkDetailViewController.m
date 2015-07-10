//
//  StockViewController.m
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StkDetailViewController.h"
#import "NewsDetailViewController.h"
#import "NewsListViewCell.h"
#import "ReportListViewCell.h"
#import "BulletinListViewCell.h"
#import "StockNewsViewModel.h"
#import "StkScalarView.h"
#import "StockTrendView.h"
#import "KLineChart.h"
#import "F10ViewController.h"

#import <PPiFlatSegmentedControl.h>
#import <Masonry.h>

@interface StkDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;
@property(nonatomic, strong) UIView *infoContainerView;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) StkScalarView *scalarView;
@property(nonatomic, strong) PPiFlatSegmentedControl *chartTabView;
@property(nonatomic, strong) StockTrendView *trendQuoteView;
// K线图
@property(nonatomic, strong) KLineChart *dailyKLine;
@property(nonatomic, strong) KLineChart *weeklyKLine;
@property(nonatomic, strong) KLineChart *monthlyKLine;

@property(nonatomic, strong) PPiFlatSegmentedControl *infoTabView;
@property(nonatomic, strong) UITableView *infoListView;

@property(nonatomic, assign) NSUInteger chartSelectIndex;
@property(nonatomic, assign) NSUInteger infoTabIndex;

@end

@implementation StkDetailViewController
{
    BDSecuCode *_secu;
    StockNewsViewModel *_quoteNewsViewModel;
}

- (instancetype)initWithSecuCode:(NSString *)code {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
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
    self.scalarView = [StkScalarView createView];
    [self addSubView:self.scalarView withHeight:110 andSpace:0];
    
    __weak StkDetailViewController *weakSelf = self;    // 解决block循环引用的问题
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
    self.infoTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"金信号"}, @{@"text":@"研报"}, @{@"text":@"公告"}, @{@"text":@"F10"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        if (segmentIndex == 3) {
            [weakSelf pushF10ViewController];
        }
        else {
            weakSelf.infoTabIndex = segmentIndex;
            [weakSelf loadQuoteNewsTableView];
            
            // 点击Tab后scrollView滚动到其位置
            CGFloat scrollHeight = weakSelf.scrollView.frame.size.height;
            CGFloat contentHeight = weakSelf.scrollView.contentSize.height;
            CGFloat tabViewY = weakSelf.infoTabView.frame.origin.y;
            CGFloat offsetY = tabViewY + scrollHeight > contentHeight ? contentHeight - scrollHeight : tabViewY;
            [weakSelf.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        }
    }];
    self.infoTabView.color = RGB(7, 9, 8, 1);
    self.infoTabView.borderWidth = 1;
    self.infoTabView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
    self.infoTabView.selectedColor = RGB(30, 30, 30, 1);
    self.infoTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214, 1)};
    self.infoTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
    [self addSubView:self.infoTabView withHeight:30 andSpace:2];
    
    /* 新闻视图容器 */
    self.infoContainerView = [[UIView alloc] init];
    self.infoContainerView.backgroundColor = [UIColor clearColor];
    [self addSubView:self.infoContainerView withHeight:0 andSpace:2];
    
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
            if (height != 0) {
                make.height.mas_equalTo(height);
            }
        }];
    }
}


#pragma mark - loading Data and View

// 订阅个股相关数据
- (void)loadData {
    if (_secu) {
        _quoteNewsViewModel = [[StockNewsViewModel alloc] initWithCode:_secu.bdCode];
        
        // 显示股票代码及名称
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", _secu.name, _secu.trdCode];
        [self.titleLabel sizeToFit];
        // 载入行情指标
        [self.scalarView loadDataWithCode:_secu.bdCode];
        // 载入分时、K线视图
        [self loadChartView];
        // 载入新闻列表视图
        [self loadQuoteNewsTableView];
    }
}

// 加载分时、K线视图
- (void)loadChartView {
    for (UIView *sub in self.chartContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_chartSelectIndex) {
        case 0: {
            if (self.trendQuoteView == nil) {
                self.trendQuoteView = [[StockTrendView alloc] initWithFrame:CGRectMake(0, 0, 320, 180) andCode:_secu.bdCode];
            }
            [self.trendQuoteView subscribeTrendLineAndQuoteWithType:TRENDLINE_1];
            [self.chartContainerView addSubview:self.trendQuoteView];
            break;
        }
        case 1:
            if (self.trendQuoteView == nil) {
                self.trendQuoteView = [[StockTrendView alloc] initWithFrame:CGRectMake(0, 0, 320, 180) andCode:_secu.bdCode];
            }
            [self.trendQuoteView subscribeTrendLineAndQuoteWithType:TRENDLINE_5];
            [self.chartContainerView addSubview:self.trendQuoteView];
            break;
        case 2:
            if (self.dailyKLine == nil) {
                self.dailyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.dailyKLine.number = 60;
                [self.dailyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.dailyKLine];
            break;
        case 3:
            if (self.weeklyKLine == nil) {
                self.weeklyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.weeklyKLine.type = KLINE_WEEK;
                self.weeklyKLine.number = 60;
                [self.weeklyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.weeklyKLine];
            break;
        case 4:
            if (self.monthlyKLine == nil) {
                self.monthlyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.monthlyKLine.type = KLINE_MONTH;
                self.monthlyKLine.number = 60;
                [self.monthlyKLine loadDataWithSecuCode:_secu.bdCode];
            }
            [self.chartContainerView addSubview:self.monthlyKLine];
            break;
        default:
            break;
    }
}

// 加载个股资讯
- (void)loadQuoteNewsTableView {
    if (self.infoListView == nil) {
        self.infoListView = [UITableView new];
        self.infoListView.backgroundColor = [UIColor clearColor];
        [self.infoListView setRowHeight:60.0];
        self.infoListView.bounces = NO;
        self.infoListView.delegate = self;
        self.infoListView.dataSource = self;
        self.infoListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.infoContainerView addSubview:self.infoListView];
        
        [self.infoListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.infoContainerView);
            make.height.mas_equalTo(300);
        }];
    }
    
    switch (_infoTabIndex) {
        case 0: {
            if (_quoteNewsViewModel.newsList.count > 0) {
                [self.infoListView reloadData];
            }
            else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_quoteNewsViewModel loadNews];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.infoListView reloadData];
                    });
                });
            }
        }
            break;
        case 1:
        {
            if (_quoteNewsViewModel.reportList.count > 0) {
                [self.infoListView reloadData];
            }
            else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_quoteNewsViewModel loadReport];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.infoListView reloadData];
                    });
                });
            }
        }
            break;
        case 2:
        {
            if (_quoteNewsViewModel.bulletinList.count > 0) {
                [self.infoListView reloadData];
            }
            else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_quoteNewsViewModel loadBulletin];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.infoListView reloadData];
                    });
                });
            }
        }
            break;
    }
}


#pragma mark - Table delegate and dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (_infoTabIndex) {
        case 0:
            return _quoteNewsViewModel.newsList.count;
        case 1:
            return _quoteNewsViewModel.reportList.count;
        case 2:
            return _quoteNewsViewModel.bulletinList.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_infoTabIndex) {
        case 0: {
            NewsListViewCell *cell = (NewsListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewsListCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewsListViewCell" owner:self options:nil];
                for (id obj in nib) {
                    if ([obj isKindOfClass:[NewsListViewCell class]]) {
                        cell = obj;
                        cell.title.textColor = RGB(208, 208, 208, 1);
                        cell.date.textColor = RGB(46, 116, 147, 1);
                    }
                }
            }
            BDNews *news = (BDNews *)_quoteNewsViewModel.newsList[indexPath.row];
            cell.news = news;
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = [UIColor blackColor];
            }
            else {
                cell.backgroundColor = RGB(30, 30, 30, 1);
            }
            return cell;
        }
        case 1: {
            ReportListViewCell *cell = (ReportListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReportListCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReportListViewCell" owner:self options:nil];
                for (id obj in nib) {
                    if ([obj isKindOfClass:[ReportListViewCell class]]) {
                        cell = obj;
                        cell.title.textColor = RGB(208, 208, 208, 1);
                        cell.date.textColor = RGB(46, 116, 147, 1);
                    }
                }
            }
            BDReport *report = (BDReport *)_quoteNewsViewModel.reportList[indexPath.row];
            cell.report = report;
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = [UIColor blackColor];
            }
            else {
                cell.backgroundColor = RGB(30, 30, 30, 1);
            }
            return cell;
        }
        case 2: {
            BulletinListViewCell *cell = (BulletinListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BulletinListCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BulletinListViewCell" owner:self options:nil];
                for (id obj in nib) {
                    if ([obj isKindOfClass:[BulletinListViewCell class]]) {
                        cell = obj;
                        cell.title.textColor = RGB(208, 208, 208, 1);
                        cell.date.textColor = RGB(46, 116, 147, 1);
                    }
                }
            }
            BDBulletin *bulletin = (BDBulletin *)_quoteNewsViewModel.bulletinList[indexPath.row];
            cell.bulletin = bulletin;
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = [UIColor blackColor];
            }
            else {
                cell.backgroundColor = RGB(30, 30, 30, 1);
            }
            return cell;
        }
        default:
            return nil;
    }
}

// 动态设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 预设cell高度，可以提高性能
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BDNews *news = _quoteNewsViewModel.newsList[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewsDetailViewController *newsDetail = [storyboard instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
    newsDetail.newsId = news.innerId;
    [self.navigationController pushViewController:newsDetail animated:YES];
}


#pragma mark - Navigation

// 打开F10视图控制器
- (void)pushF10ViewController {
    F10ViewController *f10 = [[F10ViewController alloc] init];
    [f10 loadF10PageWithSecuCode:_secu.bdCode];
    [self.navigationController pushViewController:f10 animated:YES];
}


#pragma mark

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEYBOARD_WIZARD_NOTIFICATION object:nil];
    NSLog(@"StkDetailViewController dealloc (%@)", _secu.bdCode);
}

@end