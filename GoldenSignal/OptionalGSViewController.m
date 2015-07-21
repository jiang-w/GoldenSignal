//
//  OptionalGSViewController.m
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/12/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "OptionalGSViewController.h"//自选股金信号新闻页面
#import "BDSectService.h"
#import "NewsEventListViewController.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import "AutoLayoutNewsEventListCell.h"

#import "BDNewsService.h"
#import "OptionalGSModel.h"
#import "NewsEventMainViewController.h"
#import "NewsEventDetailViewController.h"

#import "BDNews.h"

@interface OptionalGSViewController ()
{    
    dispatch_queue_t loadDataQueue;
    long _OpGoldSignId;
    OptionalGSModel *_optionalGSModel;
    NSMutableArray *_dataArray;
    
    BOOL isRefresh;
}

@end

@implementation OptionalGSViewController

- (id)initWithOpGoldSignId:(long)OpGoldSignId {
    self = [super init];
    if (self) {
        _OpGoldSignId = OpGoldSignId;
        _optionalGSModel = [[OptionalGSModel alloc] init];
        loadDataQueue = dispatch_queue_create("loadData", nil);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addCustomStockChanged2:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(removeCustomStockChanged2:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
//    [self performSelectorInBackground:@selector(loadModelAndData) withObject:nil];
    [self loadModelAndData];
}


- (void)loadModelAndData{
    //数据源 添加或删除时 需要变动
    NSArray *BDCodeArray = [BDStockPool sharedInstance].codes;
    
    dispatch_async(loadDataQueue, ^{
        [_optionalGSModel loadNewsWithTagId:_OpGoldSignId andBdCode:BDCodeArray];
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    /* 设置表视图刷新 */
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    // 设置文字
    [self.tableView.header setTitle:@"下拉可以刷新" forState:MJRefreshHeaderStateIdle];
    [self.tableView.header setTitle:@"松开立即刷新" forState:MJRefreshHeaderStatePulling];
    [self.tableView.header setTitle:@"正在刷新..." forState:MJRefreshHeaderStateRefreshing];
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    
}

#pragma mark -- 刷新rereshing
// 下拉刷新数据
- (void)headerRereshing
{
    dispatch_async(loadDataQueue, ^{
        [_optionalGSModel reloadNews];
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        });
    });
    
}

// 上拉加载更多数据
- (void)footerRereshing
{
    dispatch_async(loadDataQueue, ^{
        [_optionalGSModel loadMoreNews];
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.footer endRefreshing];
        });
    });
}

//通知
- (void)addCustomStockChanged2:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"add"]) {
        [self loadModelAndData];
    }
}
- (void)removeCustomStockChanged2:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"remove"]) {
        [self loadModelAndData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _optionalGSModel.newsList.count;
//    return _dataAry.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AutoLayoutNewsEventListCell *newsCell = (AutoLayoutNewsEventListCell *)[tableView dequeueReusableCellWithIdentifier:@"NewsListCell"];
    if (newsCell == nil) {
        newsCell = [[AutoLayoutNewsEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsListCell"];
    }
    newsCell.newsEvent = _optionalGSModel.newsList[indexPath.row];
    
    return newsCell;
}


#pragma mark -- 动态设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tabCell;
    if (!tabCell) {
        tabCell  = [[AutoLayoutNewsEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsListCell"];
    }
    AutoLayoutNewsEventListCell *cell = (AutoLayoutNewsEventListCell *)tabCell;
    cell.newsEvent = _optionalGSModel.newsList[indexPath.row];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //    NSLog(@"(%ld,%ld) w=%f, h=%f", indexPath.section, indexPath.row, size.width, size.height + 1);
    return 1  + size.height;
}

#pragma mark -- 预设cell高度，可以提高性能
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

#pragma mark -- 选中单元格后执行 跳转页面 返回到CustomStockViewController页里跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoLayoutNewsEventListCell *cell = (AutoLayoutNewsEventListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectRowNews:)]) {
        [self.delegate didSelectRowNews:cell.newsEvent];
    }
}



/*
#pragma mark - Navigation
//s. 设置跳转 系统方法，sb连线
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller..

}
*/

@end
