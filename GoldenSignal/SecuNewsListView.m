//
//  SecuNewsListView.m
//  GoldenSignal
//
//  Created by Frank on 15/7/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SecuNewsListView.h"
#import "BDCoreService.h"
#import "NewsListViewCell.h"
#import "NewsDetailViewController.h"

#import <MBProgressHUD.h>

@interface SecuNewsListView ()

@end

@implementation SecuNewsListView
{
    NSMutableArray *_newsList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self.tableView setRowHeight:60.0];
    
    _newsList = [NSMutableArray array];
    if (self.secuCode) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self loadNewsListWithSecuCode:self.secuCode];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
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
    return _newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    BDSecuNewsList *news = (BDSecuNewsList *)_newsList[indexPath.row];
    cell.title.text = news.title;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    cell.date.text = [formatter stringFromDate:news.date];
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor blackColor];
    }
    else {
        cell.backgroundColor = RGB(30, 30, 30, 1);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 预设cell高度，可以提高性能
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BDSecuNewsList *news = _newsList[indexPath.row];
    NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
    detail.contentId = news.contentId;
    [self pushViewController:detail animated:YES];
}


- (void)loadNewsListWithSecuCode:(NSString *)code {
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
    NSArray *idxList = @[@"000001", @"000002", @"000003", @"000010", @"000016", @"000300", @"399001", @"399005", @"399006"];
    NSArray *data;
    if ([idxList containsObject:secu.trdCode]) {    // 是否为市场指数
        NSDictionary *paramDic = @{@"ID": [NSNumber numberWithInt:0],
                                   @"COUNT": [NSNumber numberWithInt:5]};
        data = [[BDCoreService new] syncRequestDatasourceService:1580 parameters:paramDic query:nil];
    }
    else {
        NSDictionary *paramDic = @{@"ID": [NSNumber numberWithInt:0],
                                   @"COUNT": [NSNumber numberWithInt:5]};
        data = [[BDCoreService new] syncRequestDatasourceService:1584 parameters:paramDic query:nil];
    }
    [_newsList removeAllObjects];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    for (NSDictionary *item in data) {
        BDSecuNewsList *news = [BDSecuNewsList new];
        news.date = [formatter dateFromString:item[@"PUB_DT"]];
        news.title = item[@"TIT"];
        news.contentId = [item[@"CONT_ID"] longValue];
        [_newsList addObject:news];
    }
}

@end
