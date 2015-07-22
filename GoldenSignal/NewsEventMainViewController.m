//
//  NewsMainViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsEventMainViewController.h"
#import "NewsEventDetailViewController.h"
#import <Masonry.h>

@interface NewsEventMainViewController ()
{
    NSArray *_tabArray;
    NSMutableDictionary *_controllerDic;
}

@end

@implementation NewsEventMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tabArray = [self getTabArray];
    _controllerDic = [NSMutableDictionary dictionary];
    
    titleTabVC = [[TitleTabViewController alloc] initWithNibName:@"TitleTabViewController" bundle:nil];
    titleTabVC.delegate = self;
    [self.view addSubview:titleTabVC.view];
    [titleTabVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.view).with.offset(64);
    }];

    CGFloat pageWidth = CGRectGetWidth(self.view.frame);
    CGFloat pageHeight = CGRectGetHeight(self.view.frame)-49-94;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 94, pageWidth, pageHeight)];
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(pageWidth * _tabArray.count , pageHeight);
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    titleTabVC.tabArray = _tabArray;
    
    /* 接收用户定制标签更改的通知 */
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(refreshView) name:TAGS_CHANGED_NOTIFICATION object:nil];
    [notification addObserver:self selector:@selector(refreshView) name:TAGS_SORTED_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addControllerWithIndex:(NSInteger)index {
    UIViewController *controller;
    NSString *code = [[[titleTabVC.tabArray objectAtIndex:index] allKeys] firstObject];
    NSNumber *tagId = [NSNumber numberWithInt:[code intValue]];
    NewsEventListViewController *newsList = [[NewsEventListViewController alloc] initWithTagId:tagId andSecuCodes:nil];
    newsList.delegate = self;
    controller = newsList;
    
    if (controller) {
        controller.view.frame = CGRectMake(index * CGRectGetWidth(scrollView.frame), 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        [scrollView addSubview:controller.view];
        NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
        [_controllerDic setObject:controller forKey:key];
    }
}

- (NSArray *)getTabArray {
    NSMutableArray *tabArray = [NSMutableArray array];
    NSArray *tags = [BDCustomTagCollection sharedInstance].tags;
    for (BDNewsTag *tag in tags) {
        [tabArray addObject:@{[NSString stringWithFormat:@"%ld", tag.innerId] : tag.name}];
    }
    [tabArray insertObject:@{@"0" : @"全部"} atIndex:0];
    return [NSArray arrayWithArray:tabArray];
}

- (void)refreshView {
    _tabArray = [self getTabArray];
    CGFloat pageWidth = CGRectGetWidth(self.view.frame);
    CGFloat pageHeight = CGRectGetHeight(self.view.frame)-49-94;
    scrollView.contentSize = CGSizeMake(pageWidth * _tabArray.count , pageHeight);
    titleTabVC.tabArray = _tabArray;
    
    NSArray *allKeys = [NSArray arrayWithArray:_controllerDic.allKeys];
    for (NSString *key in allKeys) {
        NSRange range = [key rangeOfString:@"_"];
        int index = [[key substringToIndex:range.location] intValue];
        NSString *code = [key substringFromIndex:(range.location + range.length)];

        if (index < _tabArray.count) {
            if (![[[_tabArray[index] allKeys] firstObject] isEqualToString:code]) {
                UIViewController *vc = (UIViewController *)_controllerDic[key];
                [vc.view removeFromSuperview];
                [_controllerDic removeObjectForKey:key];
            }
        }
        else {
            UIViewController *vc = (UIViewController *)_controllerDic[key];
            [vc.view removeFromSuperview];
            [_controllerDic removeObjectForKey:key];
        }
    }
}

#pragma mark navigation

// 设置跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowNewsDetail"])
    {
        BDNews *news = (BDNews *)sender;
        NewsEventDetailViewController *detailVC = (NewsEventDetailViewController *)segue.destinationViewController;
        detailVC.newsId = news.innerId;
    }
}

#pragma mark - NewsListView Delegate

- (void)didSelectNewsEvent:(BDNews *)news {
    [self performSegueWithIdentifier:@"ShowNewsDetail" sender:news];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
    NSInteger index = scroll.contentOffset.x / 320;
    [titleTabVC changeSelectedIndex:index];
}

#pragma mark - TitleTabView Delegate

- (void)didChangedTabIndex:(NSInteger)index {
    if (index < titleTabVC.tabArray.count) {
        NSString *code = [[[titleTabVC.tabArray objectAtIndex:index] allKeys] firstObject];
        NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
        NewsEventListViewController *controller = [_controllerDic objectForKey:key];
        if (controller == nil) {
            [self addControllerWithIndex:index];
        }
        
        [scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(scrollView.frame) * index, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame)) animated:YES];
    }
}

@end
