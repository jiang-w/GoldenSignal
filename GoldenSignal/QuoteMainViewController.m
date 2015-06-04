//
//  QuoteMainViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteMainViewController.h"
#import "StockViewController.h"
#import "SectCollectionViewController.h"
#import "QuoteHomeViewController.h"
#import <Masonry.h>

@interface QuoteMainViewController ()
{
    NSMutableArray *_sectArray;
    NSMutableDictionary *_controllerDic;
}

@end

@implementation QuoteMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _controllerDic = [NSMutableDictionary dictionary];
    _sectArray = [NSMutableArray arrayWithArray:@[@{@"home": @"首页"}, @{@"100924": @"A股"}, @{@"100839": @"指数"}, @{@"100929": @"创业板"},  @{@"100943": @"沪深300"}, @{@"more": @"更多"}]];
    
//    if (IOS_7) {
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//    }
    
    titleTabVC = [[TitleTabViewController alloc] initWithNibName:@"TitleTabViewController" bundle:nil];
    titleTabVC.delegate = self;
    [self.view addSubview:titleTabVC.view];
    [titleTabVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.view).with.offset(64);
    }];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 94, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-49-94)];
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame) * _sectArray.count , CGRectGetHeight(scrollView.frame));
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    titleTabVC.tabArray = _sectArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    for (int i = 0; i < _sectArray.count; i++) {
        if (i != titleTabVC.selectedIndex) {
            [self removeControllerWithIndex:i];
        }
    }
}

- (void)addControllerWithIndex:(NSInteger)index {
    UIViewController *controller;
    NSString *code = [[[_sectArray objectAtIndex:index] allKeys] firstObject];
    if ([code isEqualToString:@"home"]) {
        QuoteHomeViewController *home = [[QuoteHomeViewController alloc] initWithNibName:@"QuoteHomeViewController" bundle:nil];
        controller = home;
    }
    else if ([code isEqualToString:@"more"]) {
        SectCollectionViewController *sect = [[SectCollectionViewController alloc] initWithNibName:@"SectCollectionViewController" bundle:nil];
        sect.delegate = self;
        controller = sect;
    }
    else {
        SectQuoteViewController *quote = [[SectQuoteViewController alloc] initWithSectId:[code integerValue]];
        quote.delegate = self;
        controller = quote;
    }
    if (controller) {
        controller.view.frame = CGRectMake(index * CGRectGetWidth(scrollView.frame), 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        [scrollView addSubview:controller.view];
        NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
        [_controllerDic setObject:controller forKey:key];
    }
}

- (void)removeControllerWithIndex:(NSInteger)index {
    NSString *code = [[[_sectArray objectAtIndex:index] allKeys] firstObject];
    NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
    SectQuoteViewController *controller = [_controllerDic objectForKey:key];
    if (controller != nil) {
        [controller.tableView removeFromSuperview];
        [_controllerDic removeObjectForKey:key];
    }
}

#pragma mark - Navigation

- (void)didSelectSecuCode:(NSString *)code {
    [self performSegueWithIdentifier:@"StockViewSegue" sender:code];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StockViewSegue"]) {
        NSString *code = (NSString *)sender;
        StockViewController *stockVC = (StockViewController *)segue.destinationViewController;
        stockVC.defaultCode = code;
    }
}

- (void)didSelectSectInfo:(BDSectInfo *)info {
    SectQuoteViewController *quote = [[SectQuoteViewController alloc] initWithSectId:info.sectId];
    [self.navigationController pushViewController:quote animated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
    NSInteger index = scroll.contentOffset.x / 320;
    [titleTabVC changeSelectedIndex:index];
}

#pragma mark - TitleTabView Delegate

- (void)didChangedTabIndex:(NSInteger)index {
    if (index < _sectArray.count) {
        NSString *code = [[[_sectArray objectAtIndex:index] allKeys] firstObject];
        NSString *key = [NSString stringWithFormat:@"%d_%@", (int)index, code];
        SectQuoteViewController *controller = [_controllerDic objectForKey:key];
        if (controller == nil) {
            [self addControllerWithIndex:index];
        }
        
        [scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(scrollView.frame) * index, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame)) animated:YES];
    }
}

@end
