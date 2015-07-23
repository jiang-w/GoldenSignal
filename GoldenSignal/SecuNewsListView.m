//
//  SecuNewsListView.m
//  GoldenSignal
//
//  Created by Frank on 15/7/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SecuNewsListView.h"
#import "BDCoreService.h"
#import "BDSectService.h"
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
    BDSecuNews *news = (BDSecuNews *)_newsList[indexPath.row];
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
    BDSecuNews *news = _newsList[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectNews:)]) {
        [self.delegate didSelectNews:news];
    }
}


- (void)loadNewsListWithSecuCode:(NSString *)code {
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
    NSArray *idxList = @[@"000001", @"000002", @"000003", @"000010", @"000016", @"000043", @"000300", @"000903", @"000905", @"399001", @"399004", @"399005", @"399006", @"399100", @"399101", @"399102", @"399106", @"399107", @"399108"];
    NSArray *data;
    if ([idxList containsObject:secu.trdCode]) {    // 是否为市场指数
        NSDictionary *paramDic = @{@"ID": [NSNumber numberWithInt:0],
                                   @"COUNT": [NSNumber numberWithInt:5]};
        data = [[BDCoreService new] syncRequestDatasourceService:1580 parameters:paramDic query:nil];
    }
    else {
        BDSectService *service = [[BDSectService alloc] init];
        NSUInteger sectId = [service getSectIdByIndexCode:secu.bdCode];
        NSDictionary *paramDic = @{@"PSIZE": [NSNumber numberWithUnsignedInteger:5],
                                   @"PINDEX": [NSNumber numberWithUnsignedInteger:1],
                                   @"sect_id": [NSNumber numberWithUnsignedInteger:sectId]};
        data = [[BDCoreService new] syncRequestDatasourceService:1585 parameters:paramDic query:nil];
    }
    [_newsList removeAllObjects];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    for (NSDictionary *item in data) {
        BDSecuNews *news = [BDSecuNews new];
        news.date = [formatter dateFromString:item[@"PUB_DT"]];
        news.title = item[@"TIT"];
        news.media = item[@"MED_NAME"];
        news.author = item[@"AUT"];
        news.abstract = item[@"ABST"];
        news.contentId = [item[@"CONT_ID"] longValue];
        [_newsList addObject:news];
    }
}


@end
