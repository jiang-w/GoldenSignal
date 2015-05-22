//
//  QuoteInformationViewModel.m
//  CBNAPP
//
//  Created by Frank on 14/12/17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StockNewsViewModel.h"
#import "BDStockNewsService.h"

@implementation StockNewsViewModel
{
    BDStockNewsService *_service;
}

- (id)initWithCode:(NSString *)code
{
    if (self = [super init]) {
        _newsList = [NSMutableArray arrayWithCapacity:0];
        _bulletinList = [NSMutableArray arrayWithCapacity:0];
        _reportList = [NSMutableArray arrayWithCapacity:0];
        _secuCode = [code copy];
        _pageSize = 5;
        _service = [[BDStockNewsService alloc] init];
    }
    return self;
}

// 加载新闻数据
- (void)loadNews {
    long lastSN = 0;
    if (_newsList.count > 0) {
        lastSN = [[_newsList lastObject] innerId];
    }
    @try {
        NSArray *newsArray = [_service getNewsListBySecuCode:_secuCode andQuantity:_pageSize];
        [_newsList addObjectsFromArray:newsArray];
    }
    @catch (NSException *exception) {
        
    }
}

// 加载公告数据
- (void)loadBulletin {
    long lastSN = 0;
    if (_bulletinList.count > 0) {
        lastSN = [[_bulletinList lastObject] sn];
    }
    NSArray *bulletinArray = [_service getBulletinListBySecuCode:_secuCode andQuantity:_pageSize];
    [_bulletinList addObjectsFromArray:bulletinArray];
}

// 加载研报数据
- (void)loadReport {
    long lastSN = 0;
    if (_reportList.count > 0) {
        lastSN = [[_reportList lastObject] sn];
    }
    NSArray *reportArray = [_service getReportListBySecuCode:_secuCode andQuantity:_pageSize];
    [_reportList addObjectsFromArray:reportArray];
}

@end
