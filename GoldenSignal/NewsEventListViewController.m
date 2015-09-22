//
//  NewsListViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsEventListViewController.h"
#import "NewsEventListViewModel.h"
#import "SlideImageViewController.h"
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import "AutoLayoutNewsEventListCell.h"

@interface NewsEventListViewController ()

@property(nonatomic, strong) AutoLayoutNewsEventListCell *sampleCell;

@end

static NSString *tableCellIdentifier = @"NewsListCell";

@implementation NewsEventListViewController
{
    NSNumber *_tagId;
    NSArray *_codes;
    NewsEventListViewModel *_vm;
    dispatch_queue_t loadDataQueue;
    UILabel *_label;//没数据时显示的信息
}

- (id)initWithTagId:(NSNumber *)tagId andSecuCodes:(NSArray *)codes {
    self = [super init];
    if (self) {
        _tagId = tagId;
        _codes = codes;
        _vm = [[NewsEventListViewModel alloc] init];
        loadDataQueue = dispatch_queue_create("loadData", nil);
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(customStockChanged:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
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
    
    [self getRequestDataResource];
    
    _label = [[UILabel alloc]init];
    //    _label.backgroundColor = [UIColor yellowColor];
    _label.frame = CGRectMake(0, 30, self.view.frame.size.width, 25);
    _label.font = [UIFont systemFontOfSize:14];
    _label.textAlignment = NSTextAlignmentCenter;
    
}

- (void)getRequestDataResource{
    
    dispatch_async(loadDataQueue, ^{
        [_vm loadNewsEventWithTagId:_tagId andSecuCodes:_codes];
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self informationLabel];
            
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}


- (void)informationLabel{
    if (_tagId == nil) {//自选股的金信号
        _label.text = @"";
        if (_codes.count == 0) {
            [self.tableView addSubview:_label];
            _label.text = @"请先添加自选股然后查看相关的数据";
        }
        else if (_codes.count != 0 && _vm.newsList.count == 0) {
            [self.tableView addSubview:_label];
            _label.text = @"此栏目近期没有相关的数据";
        }
        else {
            _label.text = @"";
            [_label removeFromSuperview];
        }
    }
    else {
        if (_codes.count == 0 && _vm.newsList.count == 0) {
            [self.tableView addSubview:_label];
            _label.text = @"此栏目近期没有相关的数据";
        }
    }
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
    cell.newsEvent = _vm.newsList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

// 动态设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.sampleCell) {
        self.sampleCell  = [[AutoLayoutNewsEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier];
    }
    self.sampleCell.newsEvent = _vm.newsList[indexPath.row];
    CGSize size = [self.sampleCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectNewsEvent:)]) {
        [self.delegate didSelectNewsEvent:cell.newsEvent];
    }
}


#pragma mark rereshing

// 下拉刷新数据
- (void)headerRereshing
{
    dispatch_async(loadDataQueue, ^{
        [_vm reloadNewsEvent];
        dispatch_sync(dispatch_get_main_queue(), ^{
            _label.text = @"";
            [_label removeFromSuperview];
//            [self getRequestDataResource];
            [self informationLabel];
            
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        });
    });
}

// 上拉加载更多数据
- (void)footerRereshing
{
    dispatch_async(loadDataQueue, ^{
        [_vm loadMoreNewsEvent];
        dispatch_sync(dispatch_get_main_queue(), ^{
            _label.text = @"";
            [_label removeFromSuperview];
//            [self getRequestDataResource];
            [self informationLabel];
            
            [self.tableView reloadData];
            [self.tableView.footer endRefreshing];
        });
    });
}

// 自选股变化后的通知事件（用于自选股金信号视图）
- (void)customStockChanged:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"add"] || [op isEqualToString:@"remove"]) {
        _codes = [BDStockPool sharedInstance].codes;
        [self getRequestDataResource];
//        if (_tagId == nil) {
//            dispatch_async(loadDataQueue, ^{
//                _codes = [BDStockPool sharedInstance].codes;
//                [_vm loadNewsEventWithTagId:_tagId andSecuCodes:_codes];
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            });
//            
//        }
    }
}

@end
