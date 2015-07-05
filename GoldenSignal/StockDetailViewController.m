//
//  StockViewController.m
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StockDetailViewController.h"
#import "NewsDetailViewController.h"
#import "NewsListViewCell.h"
#import "ReportListViewCell.h"
#import "BulletinListViewCell.h"
#import "BDQuotationService.h"
#import "StockNewsViewModel.h"
#import "F10ViewController.h"
#import "KLineChart.h"

#import "Masonry.h"

@interface StockDetailViewController ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;
@property(nonatomic, strong) UIView *infoContainerView;

// K线图
@property(nonatomic, strong) KLineChart *dailyKLine;
@property(nonatomic, strong) KLineChart *weeklyKLine;
@property(nonatomic, strong) KLineChart *monthlyKLine;

@property(nonatomic, assign) NSUInteger chartTabIndex;
@property(nonatomic, assign) NSUInteger infoTabIndex;

@end

@implementation StockDetailViewController
{
    NSString *_code;
    StockNewsViewModel *_quoteNewsViewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.scrollView.delegate = self;

    [self loadSubview];
    [self layoutSubView];
    
    if (self.defaultCode != nil) {
        [self subscribeQuotationWithCode:self.defaultCode];
    }
    else {
        [self subscribeQuotationWithCode:@"600036.SH"];
    }
    
    // 接收键盘精灵通知
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(changeSubscribe:) name:KEYBOARD_WIZARD_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

// 加载子视图
- (void)loadSubview {
    self.containerView = [UIView new];
    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    /* 行情指标 */
    indicatorsView = [[[NSBundle mainBundle] loadNibNamed:@"IndicatorsView" owner:self options:nil] objectAtIndex:0];
    [self.containerView addSubview:indicatorsView];
    
    __weak StockDetailViewController *weakSelf = self;    // 解决block循环引用的问题
    /* 行情走势图Tab */
    chartTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"分时"}, @{@"text":@"五日"}, @{@"text":@"日K"}, @{@"text":@"周K"}, @{@"text":@"月K"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        weakSelf.chartTabIndex = segmentIndex;
        [weakSelf loadChartView];
    }];
    chartTabView.color = RGB(7, 9, 8, 1);
    chartTabView.borderWidth = 1;
    chartTabView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
    chartTabView.selectedColor = RGB(30, 30, 30, 1);
    chartTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214, 1)};
    chartTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
    [self.containerView addSubview:chartTabView];
    
    /* 分时、K线容器视图 */
    self.chartContainerView = [UIView new];
    self.chartContainerView.backgroundColor = RGB(30, 30, 30, 1);
    [self.containerView addSubview:self.chartContainerView];

    /* 资讯Tab */
    infoTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"金信号"}, @{@"text":@"研报"}, @{@"text":@"公告"}, @{@"text":@"F10"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        
        if (segmentIndex == 3) {
            [weakSelf performSegueWithIdentifier:@"F10ViewSegue" sender:_code];
        }
        else {
            weakSelf.infoTabIndex = segmentIndex;
            [weakSelf loadQuoteNewsTableView];

            CGFloat scrollHeight = self.scrollView.frame.size.height;
            CGFloat contentHeight = self.scrollView.contentSize.height;
            CGFloat tabViewY = infoTabView.frame.origin.y;
            CGFloat offsetY = tabViewY + scrollHeight > contentHeight ? contentHeight - scrollHeight : tabViewY;
            [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        }
    }];
    infoTabView.color = RGB(7, 9, 8, 1);
    infoTabView.borderWidth = 1;
    infoTabView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
    infoTabView.selectedColor = RGB(30, 30, 30, 1);
    infoTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214, 1)};
    infoTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
    [self.containerView addSubview:infoTabView];
    
    /* 新闻视图容器 */
    self.infoContainerView = [UIView new];
    self.infoContainerView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.infoContainerView];
}

// 设置子视图布局
-(void)layoutSubView {
    UIView *lastView = nil;
    if (indicatorsView) {
        [indicatorsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.containerView);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(6);
            }
            else {
                make.top.mas_equalTo(self.containerView.mas_top);
            }
            make.height.mas_equalTo(110);
        }];
        lastView = indicatorsView;
    }
    
    if (chartTabView) {
        [chartTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.containerView);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(6);
            }
            else {
                make.top.mas_equalTo(self.containerView.mas_top);
            }
            make.height.mas_equalTo(30);
        }];
        lastView = chartTabView;
    }
    
    if (self.chartContainerView) {
        [self.chartContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.containerView);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(6);
            }
            else {
                make.top.mas_equalTo(self.containerView.mas_top);
            }
            make.height.mas_equalTo(180);
        }];
        lastView = self.chartContainerView;
    }

    if (infoTabView) {
        [infoTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.containerView);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(6);
            }
            else {
                make.top.mas_equalTo(self.containerView.mas_top);
            }
            make.height.mas_equalTo(30);
        }];
        lastView = infoTabView;
    }
    
    if (self.infoContainerView) {
        [self.infoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.containerView);
            if (lastView) {
                make.top.mas_equalTo(lastView.mas_bottom);
            }
            else {
                make.top.mas_equalTo(self.containerView.mas_top);
            }
        }];
        lastView = self.infoContainerView;
    }
    
    if (lastView) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastView.mas_bottom);
        }];
    }
}


#pragma mark - loading Data and View

// 收到键盘精灵通知后，触发
//- (void)changeSubscribe:(NSNotification *)notification {
//    NSDictionary *dic = notification.userInfo;
//    NSString *bdCode = dic[@"BD_CODE"];
//    [self subscribeQuotationWithCode:bdCode];
//}

// 订阅个股相关数据
- (void)subscribeQuotationWithCode:(NSString *)code {
    if (![code isEqualToString:_code]) {
        BDSecuCode *secuCode = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
        if (secuCode) {
            _code = code;
            _quoteNewsViewModel = [[StockNewsViewModel alloc] initWithCode:code];
            
            // 显示股票代码及名称
            self.name.text = [NSString stringWithFormat:@"%@(%@)", secuCode.name, secuCode.trdCode];
            // 载入行情指标
            [self loadIndicatorsView];
            // 载入分时、K线视图
            [self loadChartView];
            // 载入新闻列表视图
            [self loadQuoteNewsTableView];
        }
    }
}

// 加载行情指标
- (void)loadIndicatorsView {
    if (indicatorsView == nil) {
        indicatorsView = [[[NSBundle mainBundle] loadNibNamed:@"IndicatorsView" owner:self options:nil] objectAtIndex:0];
    }
    if (![indicatorsView.code isEqualToString:_code]) {
        [indicatorsView subscribeIndicatorsWithCode:_code];
    }
}

// 加载分时、K线视图
- (void)loadChartView {
    for (UIView *sub in self.chartContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_chartTabIndex) {
        case 0: {
            if (trendQuoteView == nil || ![trendQuoteView.code isEqualToString:_code]) {
                trendQuoteView = [[StockTrendView alloc] initWithFrame:CGRectMake(0, 0, 320, 180) andCode:_code];
            }
            [self.chartContainerView addSubview:trendQuoteView];
            [trendQuoteView subscribeTrendLineAndQuoteWithType:TRENDLINE_1];
            break;
        }
        case 1:
            if (trendQuoteView == nil || ![trendQuoteView.code isEqualToString:_code]) {
                trendQuoteView = [[StockTrendView alloc] initWithFrame:CGRectMake(0, 0, 320, 180) andCode:_code];
            }
            [self.chartContainerView addSubview:trendQuoteView];
            [trendQuoteView subscribeTrendLineAndQuoteWithType:TRENDLINE_5];
            break;
        case 2:
            if (self.dailyKLine == nil) {
                self.dailyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.dailyKLine.number = 60;
                [self.dailyKLine loadDataWithSecuCode:_code];
            }
            [self.chartContainerView addSubview:self.dailyKLine];
            break;
        case 3:
            if (self.weeklyKLine == nil) {
                self.weeklyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.weeklyKLine.type = KLINE_WEEK;
                self.weeklyKLine.number = 60;
                [self.weeklyKLine loadDataWithSecuCode:_code];
            }
            [self.chartContainerView addSubview:self.weeklyKLine];
            break;
        case 4:
            if (self.monthlyKLine == nil) {
                self.monthlyKLine = [[KLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.monthlyKLine.type = KLINE_MONTH;
                self.monthlyKLine.number = 60;
                [self.monthlyKLine loadDataWithSecuCode:_code];
            }
            [self.chartContainerView addSubview:self.monthlyKLine];
            break;
        default:
            break;
    }
}

// 加载个股资讯
- (void)loadQuoteNewsTableView {
    if (infoListView == nil) {
        infoListView = [UITableView new];
        infoListView.backgroundColor = [UIColor clearColor];
        [infoListView setRowHeight:60.0];
        infoListView.bounces = NO;
        infoListView.delegate = self;
        infoListView.dataSource = self;
        infoListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.infoContainerView addSubview:infoListView];
        
        [infoListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.infoContainerView);
            make.height.mas_equalTo(300);
        }];
    }
    
    switch (_infoTabIndex) {
        case 0: {
            if (_quoteNewsViewModel.newsList.count > 0) {
                [infoListView reloadData];
            }
            else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_quoteNewsViewModel loadNews];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [infoListView reloadData];
                    });
                });
            }
        }
            break;
        case 1:
        {
            if (_quoteNewsViewModel.reportList.count > 0) {
                [infoListView reloadData];
            }
            else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_quoteNewsViewModel loadReport];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [infoListView reloadData];
                    });
                });
            }
        }
            break;
        case 2:
        {
            if (_quoteNewsViewModel.bulletinList.count > 0) {
                [infoListView reloadData];
            }
            else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_quoteNewsViewModel loadBulletin];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [infoListView reloadData];
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
    [self performSegueWithIdentifier:@"QuotationViewSegue" sender:news];
}

#pragma mark navigation

// 设置跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"QuotationViewSegue"]) {
        BDNews *news = (BDNews *)sender;
        NewsDetailViewController *detailVC = (NewsDetailViewController *)segue.destinationViewController;
        detailVC.newsId = news.innerId;
    }
    if ([segue.identifier isEqualToString:@"F10ViewSegue"]) {
        NSString *code = (NSString *)sender;
        F10ViewController *f10VC = (F10ViewController *)segue.destinationViewController;
        f10VC.code = code;
    }
}

// 返回上一个试图控制器
- (IBAction)prevBtnOnClick:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEYBOARD_WIZARD_NOTIFICATION object:nil];
    NSLog(@"StockDetailViewController dealloc");
}

@end
