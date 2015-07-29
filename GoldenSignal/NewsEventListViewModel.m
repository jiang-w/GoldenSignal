//
//  NewsListViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsEventListViewModel.h"
#import "BDNewsEventService.h"

@implementation NewsEventListViewModel
{
    NSNumber *_tagId;
    NSArray *_codes;
    BDNewsEventService *_service;
}

- (id)init
{
    if (self = [super init]) {
        _newsList = [NSMutableArray arrayWithCapacity:0];
        _pageSize = 10;
        _service = [BDNewsEventService new];
    }
    return self;
}

- (void)loadNewsEventWithTagId:(NSNumber *)tagId andSecuCodes:(NSArray *)codes {
    _tagId = tagId;
    _codes = codes;
    [self.newsList removeAllObjects];
    if (_tagId != nil || (_codes != nil && _codes.count > 0)) {
        NSArray *newsArray = [_service getNewsEventListBySecuCodes:_codes tagId:[_tagId longValue] lastId:0 quantity:self.pageSize];
        [self.newsList addObjectsFromArray:newsArray];
    }
}

// 加载更多的新闻
- (void)loadMoreNewsEvent
{
    if (_tagId != nil || (_codes != nil && _codes.count > 0)) {
        long lastId = self.newsList.count > 0 ? [[self.newsList lastObject] innerId]:0;
        NSArray *newsArray = [_service getNewsEventListBySecuCodes:_codes tagId:[_tagId longValue] lastId:lastId quantity:self.pageSize];
        [self.newsList addObjectsFromArray:newsArray];
    }
}

// 重新加载新闻
- (void)reloadNewsEvent
{
    if (_tagId != nil || (_codes != nil && _codes.count > 0)) {
        NSArray *newsArray = [_service getNewsEventListBySecuCodes:_codes tagId:[_tagId longValue] lastId:0 quantity:self.pageSize];
        [self.newsList removeAllObjects];
        [self.newsList addObjectsFromArray:newsArray];
    }
}

@end
