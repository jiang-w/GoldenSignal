//
//  ImportTableViewController.m
//  GoldenSignal
//
//  Created by CBD on 7/6/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

/**
 *  要闻一级页面
 */
#import "ImportTableViewController.h"
#import "BDImportService.h"
#import "BDNewsList.h"//Model
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import "ImportsTableViewCell.h"

//详情页面 调用自选股的新闻详情页面
#import "NewsDetailViewController.h"
#import "ReportDetailViewController1.h"

@interface ImportTableViewController ()
{
    BDImportService *_service;
    NSMutableArray *_allArray;
    NSMutableArray *_firstArray;
    int _pageId;//每个页面的id
    int _pageDetailId;
    
    id _temp;//标记
    long _lastId;//标记
    int _timeIndex;//请求的次数
}

@end

@implementation ImportTableViewController


- (instancetype)initWithPageId:(int)pageId{
    self = [super init];
    if (self) {
        _pageId = pageId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ImportsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ImportCell"];
   
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
    _allArray = [[NSMutableArray alloc]init];
    self.pageNumbs = 10;
    _timeIndex = 1;
    
    [self getImportNewsRequestData];
    [self refresh];
}

- (void)getImportNewsRequestData{
    _firstArray= [[NSMutableArray alloc]initWithCapacity:0];
    _service = [[BDImportService alloc] init];
    //判断上拉下拉刷新
    if (self.tableView.legendHeader.isRefreshing == YES) {
        self.pageNumbs = 10;
        _lastId = 0;
        _timeIndex = 1;
    } else if (self.tableView.legendFooter.isRefreshing == YES) {
        self.pageNumbs = 10;
        _timeIndex ++;
        [self downPullRefresh];
        return;
        
//        if (_temp == _allArray.lastObject) {
//            self.pageNumbs += 10;
//            _timeIndex ++;
//        } else {
//            [self downPullRefresh];
//            return;
//        }
    }
#pragma mark --异步加载
    dispatch_queue_t requestQueue = dispatch_queue_create("RequestData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(requestQueue , ^{
        
        if (_pageId == 1582) {
            _firstArray = [_service getImportNewsStrategyRequestDataWithPageId:_pageId cellCount:10 timeNumber:_timeIndex];
        } else {
            _firstArray = [_service getImportNewsListRequestDataWithPageId:_pageId lastCellId:0 quantity:self.pageNumbs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 相同于主线程中执行
            [self.tableView.legendHeader endRefreshing];
            [self.tableView.legendFooter endRefreshing];
            _temp = _firstArray.lastObject;
            _lastId = [_firstArray.lastObject innerId];
            _allArray = [NSMutableArray arrayWithArray:_firstArray];
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    
}

//上拉刷新 这是每次都拼接固定的条数的方法
- (void)downPullRefresh{
    if (_temp == _allArray.lastObject) {
        NSMutableArray *tempAry = [[NSMutableArray alloc]init];
        if (_pageId == 1582) {
            tempAry = [_service getImportNewsStrategyRequestDataWithPageId:_pageId cellCount:10 timeNumber:_timeIndex];
        } else {
            tempAry = [_service getImportNewsListRequestDataWithPageId:_pageId lastCellId:_lastId quantity:self.pageNumbs];
        }
        
        [self.tableView.legendFooter endRefreshing];
        _lastId = [tempAry.lastObject innerId];
        _temp = tempAry.lastObject;
        [_allArray addObjectsFromArray:tempAry];
        [self.tableView reloadData];
    } else {
        [self.tableView.legendFooter noticeNoMoreData];
        return;
    }
}


#pragma mark -- 刷新
- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf getImportNewsRequestData];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf getImportNewsRequestData];
    }];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BDNewsList *newsModel = _allArray[indexPath.row];
    ImportsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImportCell"] ;
    if (_pageId == 1582) {
        [cell showCellAndStrategyNewsModel:newsModel];
    } else {
        [cell showCellAndNewsModel:newsModel];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ImportsTableViewCell *cell = (ImportsTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//    CGFloat cellH = cell.titleLabel.frame.size.height + cell.dateLabel.frame.size.height + cell.desLabel.frame.size.height + 45 ;
    
    if (_pageId == 1582) {
        CGFloat cellH = cell.titleHeight + cell.dateLabel.frame.size.height + cell.desHeight + 60;
        return cellH;
    } else {
        CGFloat cellH = cell.titleHeight + cell.dateLabel.frame.size.height + cell.desHeight + 60;
//        DEBUGLog(@"11Debug:H%.2lf",cellH);
        return cellH;
    }
    
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat cellH = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
//    DEBUGLog(@"2222Debug:H%.2lf",cellH);
//    return cellH;
////    return 144;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (_pageId == 1582) {
        BDNewsList *newsModel = _allArray[indexPath.row];
        ReportDetailViewController1 *detail = [[ReportDetailViewController1 alloc] init];
        detail.contentId = newsModel.connectId;
        detail.hidesBottomBarWhenPushed = YES;
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        
        [uc.navigationController pushViewController:detail animated:YES];
        DEBUGLog(@"Debug:aa");
    }
    else {
        BDNewsList *newsModel = _allArray[indexPath.row];
        NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
        detail.contentId = newsModel.connectId;
        detail.hidesBottomBarWhenPushed = YES;
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        [uc.navigationController pushViewController:detail animated:YES];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
