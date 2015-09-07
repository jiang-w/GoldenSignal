//
//  ImportantMainViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/21.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "InformationMainViewController.h"
#import "ImportTableViewController.h"
#import "NewStockViewController.h"
#import <Masonry.h>

@interface InformationMainViewController ()

@property(nonatomic, strong) TitleTabViewController *titleTabVC;
@property(nonatomic, strong) UIScrollView *scrollView;

@end

@implementation InformationMainViewController
{
    NSArray *_tabArray;
    NSMutableDictionary *_controllerDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tabArray = @[@{@"1580": @"沪深"}, @{@"1581": @"宏观"}, @{@"1582": @"策略"}, @{@"1590": @"新股"}, @{@"1583": @"全球"}, @{@"1584": @"行业 "}];
    _controllerDic = [NSMutableDictionary dictionary];
    
    self.titleTabVC = [[TitleTabViewController alloc] initWithNibName:@"TitleTabViewController" bundle:nil];
    self.titleTabVC.delegate = self;
    [self.view addSubview:self.titleTabVC.view];
    [self.titleTabVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(36);
        make.top.equalTo(self.view).with.offset(64);
    }];
    
    CGFloat pageWidth = CGRectGetWidth(self.view.frame);
    CGFloat pageHeight = CGRectGetHeight(self.view.frame)-49-100;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, pageWidth, pageHeight)];
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
    //要闻各个页面 根据code不同
    if ([code isEqualToString:@"1590"]) {//新股
        NewStockViewController *NSTVC = [[NewStockViewController alloc] initWithPageId:[code intValue]];
        controller = NSTVC;
    } else {
        ImportTableViewController *ITVC = [[ImportTableViewController alloc] initWithPageId:[code intValue]];
        controller = ITVC;
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

@end
