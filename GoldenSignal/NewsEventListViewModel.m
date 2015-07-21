//
//  NewsListViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsEventListViewModel.h"
#import "BDNewsService.h"

@implementation NewsEventListViewModel
{
    BDNewsService *_service;
}

- (id)init
{
    if (self = [super init]) {
        _newsList = [NSMutableArray arrayWithCapacity:0];
        _pageSize = 10;
        _codes = nil;
        _tagId = -1;
        _service = [BDNewsService new];
    }
    return self;
}

// 根据标签加载新闻数据
- (void)loadNewsEventWithTagId:(long)tagId
{
    NSArray *newsArray = [_service getNewsEventByTagId:tagId lastId:0 quantity:self.pageSize];
    [self.newsList removeAllObjects];
    self.tagId = tagId;
    [self.newsList addObjectsFromArray:newsArray];
}

- (void)loadNewsEventWithTagId:(long)tagId andSecuCodes:(NSArray *)codes {
    NSArray *newsArray = [_service getNewsEventBySecuCodes:codes tagId:tagId lastId:0 quantity:self.pageSize];
    [self.newsList removeAllObjects];
    self.tagId = tagId;
    self.codes = codes;
    [self.newsList addObjectsFromArray:newsArray];
}

// 加载更多的新闻
- (void)loadMoreNewsEvent
{
    long lastId = self.newsList.count > 0 ? [[self.newsList lastObject] innerId]:0;
    NSArray *newsArray = [_service getNewsEventByTagId:self.tagId lastId:lastId quantity:self.pageSize];
    [self.newsList addObjectsFromArray:newsArray];
}

// 重新加载新闻
- (void)reloadNewsEvent
{
    NSArray *newsArray = [_service getNewsEventByTagId:self.tagId lastId:0 quantity:self.pageSize];
    [self.newsList removeAllObjects];
    [self.newsList addObjectsFromArray:newsArray];
}

@end
