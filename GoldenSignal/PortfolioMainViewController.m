//
//  PortfolioMainViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/21.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "PortfolioMainViewController.h"
#import "InformationsTabViewController.h"
#import "ReportTableViewController.h"
#import "StkDetailViewController.h"
#import "NewsEventDetailViewController.h"
#import "IdxDetailViewController.h"
#import <Masonry.h>

@interface PortfolioMainViewController ()

@property(nonatomic, strong) TitleTabViewController *titleTabVC;
@property(nonatomic, strong) UIScrollView *scrollView;

@end

@implementation PortfolioMainViewController
{
    NSArray *_tabArray;
    NSMutableDictionary *_controllerDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tabArray = @[@{@"quote": @"行情"}, @{@"goldenSignal": @"金信号"}, @{@"tiShi": @"提示"}, @{@"gongGao": @"公告"}, @{@"report": @"研报"}, @{@"news": @"新闻"},@{@"yeJi": @"业绩"}];
    _controllerDic = [NSMutableDictionary dictionary];
    
    self.titleTabVC = [[TitleTabViewController alloc] initWithNibName:@"TitleTabViewController" bundle:nil];
    self.titleTabVC.delegate = self;
    [self.view addSubview:self.titleTabVC.view];
    [self.titleTabVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.view).with.offset(64);
    }];
    
    CGFloat pageWidth = CGRectGetWidth(self.view.frame);
    CGFloat pageHeight = CGRectGetHeight(self.view.frame)-49-94;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 94, pageWidth, pageHeight)];
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(pageWidth * _tabArray.count , pageHeight);
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.scrollView];
    
    self.titleTabVC.tabArray = _tabArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TitleTabView Delegate

- (void)didChangedTabIndex:(NSInteger)index {
    if (index < self.titleTabVC.tabArray.count) {
        NSString *code = [[[self.titleTabVC.tabArray objectAtIndex:index] allKeys] firstObject];
        NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
        UIViewController *controller = [_controllerDic objectForKey:key];
        if (controller == nil) {
            [self addControllerWithIndex:index];
        }
        
        [self.scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.scrollView.frame) * index, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)) animated:YES];
    }
}

- (void)addControllerWithIndex:(NSInteger)index {
    UIViewController *controller;
    NSString *code = [[[self.titleTabVC.tabArray objectAtIndex:index] allKeys] firstObject];
    
    if ([code isEqualToString:@"quote"]) {
        StockPoolViewController *optionalVC = [[StockPoolViewController alloc] init];
        controller = optionalVC;
    }
    else if ([code isEqualToString:@"goldenSignal"]) {
        NewsEventListViewController *newsVC = [[NewsEventListViewController alloc] initWithTagId:nil andSecuCodes:[BDStockPool sharedInstance].codes];
        newsVC.delegate = self;
        controller = newsVC;
    }
    else if ([code isEqualToString:@"tiShi"]
             ||[code isEqualToString:@"gongGao"]
             ||[code isEqualToString:@"yeJi"]) {
        InformationsTabViewController *informationsVC = [[InformationsTabViewController alloc]initWithCodeId:code];
        informationsVC.InformationId = code;//根据传的code判断是哪个视图
        controller = informationsVC;
    }
    else if ([code isEqualToString:@"report"]
             ||[code isEqualToString:@"news"]) {
        ReportTableViewController *reportVC = [[ReportTableViewController alloc]init];
        reportVC.codeId = code;//根据传的code判断是哪个视图
        controller = reportVC;
    }

    if (controller) {
        controller.view.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
        [_scrollView addSubview:controller.view];
        NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
        [_controllerDic setObject:controller forKey:key];
    }
}


#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
    NSInteger index = scroll.contentOffset.x / CGRectGetWidth(_scrollView.frame);
    [_titleTabVC changeSelectedIndex:index];
}

#pragma mark - NewsEventListViewDelegate
- (void)didSelectNewsEvent:(BDNewsEventList *)news{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewsEventDetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"NewsEventDetail"];
    detailVC.contentId = news.innerId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
