//
//  SecuNewsListView.m
//  GoldenSignal
//
//  Created by Frank on 15/7/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SecuNewsListView.h"
#import "BDSecuNewsService.h"
#import "SecuNewsListViewCell.h"
#import "NewsDetailViewController.h"
#import "ReportDetailViewController1.h"
#import "AnnouncementDetailViewController.h"

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
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.opacity = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BDSecuNewsService *service = [[BDSecuNewsService alloc] init];
            [_newsList addObjectsFromArray:[service getListWithSecuCode:self.secuCode type:self.type quantity:5]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SecuNewsListViewCell *cell = (SecuNewsListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewsListCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SecuNewsListViewCell" owner:self options:nil];
        for (id obj in nib) {
            if ([obj isKindOfClass:[SecuNewsListViewCell class]]) {
                cell = obj;
                cell.title.textColor = RGB(208, 208, 208, 1);
                cell.date.textColor = RGB(46, 116, 147, 1);
            }
        }
    }
    BDSecuNewsList *news = (BDSecuNewsList *)_newsList[indexPath.row];
    cell.news = news;
    
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
    switch (self.type) {
        case NWS: {
            NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
            detail.contentId = news.contentId;
            [self pushViewController:detail animated:YES];
            break;
        }
        case RPT: {
            ReportDetailViewController1 *detail = [[ReportDetailViewController1 alloc] init];
            detail.contentId = news.contentId;
            [self pushViewController:detail animated:YES];
            break;
        }
        case ANNC: {
            AnnouncementDetailViewController *detail = [[AnnouncementDetailViewController alloc] init];
            detail.contentId = news.innerId;
            [self pushViewController:detail animated:YES];
            break;
        }
        default:
            break;
    }
}


@end
