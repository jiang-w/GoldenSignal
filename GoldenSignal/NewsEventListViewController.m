//
//  NewsListViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsEventListViewController.h"
#import "NewsListViewModel.h"
#import "SlideImageViewController.h"
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import "AutoLayoutNewsEventListCell.h"

@interface NewsEventListViewController ()
{
    long _tagId;
    NewsListViewModel *_vm;
    dispatch_queue_t loadDataQueue;
    
    UITableViewCell *sampleCell;
}
@end

static NSString *tableCellIdentifier = @"NewsListCell";

@implementation NewsEventListViewController

- (id)initWithTagId:(long)tagId {
    self = [super init];
    if (self) {
        _tagId = tagId;
        _vm = [[NewsListViewModel alloc] init];
        loadDataQueue = dispatch_queue_create("loadData", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[AutoLayoutNewsEventListCell class] forCellReuseIdentifier:tableCellIdentifier];
    self.tableView.rowHeight = 100;
    
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
    // 隐藏时间
    self.tableView.header.updatedTimeHidden = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中...";
    hud.opacity = 0;
    hud.activityIndicatorColor = [UIColor blackColor];
    dispatch_async(loadDataQueue, ^{
        [_vm loadNewsWithTagId:_tagId];
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _vm.newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoLayoutNewsEventListCell *cell = (AutoLayoutNewsEventListCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    if (cell == nil) {
        cell = [[AutoLayoutNewsEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier];
    }
    cell.news = _vm.newsList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

// 动态设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!sampleCell) {
        sampleCell  = [[AutoLayoutNewsEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier];
    }
    AutoLayoutNewsEventListCell *cell = (AutoLayoutNewsEventListCell *)sampleCell;
    cell.news = _vm.newsList[indexPath.row];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    NSLog(@"(%ld,%ld) w=%f, h=%f", indexPath.section, indexPath.row, size.width, size.height + 1);
    return 1  + size.height;
}

// 预设cell高度，可以提高性能
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

// 选中单元格后执行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoLayoutNewsEventListCell *cell = (AutoLayoutNewsEventListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectNews:)]) {
        [self.delegate didSelectNews:cell.news];
    }
}


#pragma mark rereshing

// 下拉刷新数据
- (void)headerRereshing
{
    [_vm reloadNews];
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
}

// 上拉加载更多数据
- (void)footerRereshing
{
    [_vm loadMoreNews];
    [self.tableView reloadData];
    [self.tableView.footer endRefreshing];
}

@end
