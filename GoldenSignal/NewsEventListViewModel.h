//
//  NewsListViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsEventListViewModel : NSObject

/**
 *  新闻列表
 */
@property(nonatomic, strong) NSMutableArray *newsList;

/**
 *  当前浏览的标签
 */
@property(nonatomic, assign) long tagId;

/**
 *  证券编码数组
 */
@property(nonatomic, strong) NSArray *codes;

/**
 *  每次请求新闻的条数（默认10）
 */
@property(nonatomic,assign) int pageSize;


/**
 *  根据标签加载新闻数据
 *
 *  @param label 新闻标签Id
 */
- (void)loadNewsEventWithTagId:(long)tagId;

/**
 *  根据标签加载新闻数据
 *
 *  @param label 新闻标签Id
 *  @param codes 证券编码数组
 */
- (void)loadNewsEventWithTagId:(long)tagId andSecuCodes:(NSArray *)codes;

/**
 *  加载更多的新闻
 */
- (void)loadMoreNewsEvent;


/**
 *  重新加载新闻(刷新)
 */
- (void)reloadNewsEvent;

@end
