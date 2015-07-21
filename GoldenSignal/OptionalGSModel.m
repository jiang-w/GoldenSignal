//
//  OptionalGSModel.m
//  GoldenSignal
//
//  Created by CBD on 6/12/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "OptionalGSModel.h"
#import "BDNewsService.h"


@implementation OptionalGSModel
{
    BDNewsService *_service;
    NSArray *_BDCodeArray;
}

- (id)init
{
    if (self = [super init]) {
        self.newsList = [NSMutableArray arrayWithCapacity:0];
        self.pageSize = 10;
        _service = [BDNewsService new];
//        _BDCodeArray = [BDStockPool sharedInstance].codes;
    }
    return self;
}

// 根据标签加载新闻数据
- (void)loadNewsWithTagId:(long)tagId andBdCode:(NSArray *)codeArray
{
    _BDCodeArray = codeArray;
    
    NSArray *newsArray = [[NSArray alloc]init];
    
    newsArray = [_service getNewsEventBySecuCodes:_BDCodeArray lastId:0 quantity:self.pageSize];
    
    [self.newsList removeAllObjects];
    self.tagId = tagId;
    [self.newsList addObjectsFromArray:newsArray];
}


// 重新加载新闻
- (void)reloadNews
{
    NSArray *newsArray = [NSArray array];
    
    newsArray = [_service getNewsEventBySecuCodes:_BDCodeArray lastId:0 quantity:self.pageSize];
    [self.newsList removeAllObjects];
    [self.newsList addObjectsFromArray:newsArray];

    
}

// 加载更多的新闻
- (void)loadMoreNews
{

    long lastId = self.newsList.count > 0 ? [[self.newsList lastObject] innerId]:0;
    NSArray *newsArray = [NSArray array];
    
    newsArray = [_service getNewsEventBySecuCodes:_BDCodeArray lastId:lastId quantity:self.pageSize];
    [self.newsList addObjectsFromArray:newsArray];
    
}

@end
