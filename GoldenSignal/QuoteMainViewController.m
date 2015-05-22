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
    _sectArray = [NSMutableArray arrayWithArray:@[@{@"100924": @"沪深A股"}, @{@"100929": @"创业板"}, @{@"100938": @"上证50"}, @{@"100941": @"深证成指"}, @{@"100943": @"沪深300"}, @{@"101932": @"中小板"}, @{@"102022": @"沪股通"}, @{@"more": @"更多"}]];
    
//    if (IOS_7) {
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//    }
    
    titleTabVC = [[TitleTabViewController alloc] initWithNibName:@"TitleTabViewController" bundle:nil];
    titleTabVC.delegate = self;
    titleTabVC.view.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 30);
    [self.view addSubview:titleTabVC.view];
    
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
    if ([code isEqualToString:@"more"]) {
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
