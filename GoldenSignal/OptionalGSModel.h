//
//  OptionalGSModel.h
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/12/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionalGSModel : NSObject

/**
 *  新闻列表
 */
@property(nonatomic, strong) NSMutableArray *newsList;

/**
 *  当前浏览的标签
 */
@property(nonatomic, assign) long tagId;

/**
 *  每次请求新闻的条数（默认10）
 */
@property(nonatomic,assign) int pageSize;


/**
 *  根据标签加载新闻数据
 *
 *  @param label 新闻标签Id
 */
- (void)loadNewsWithTagId:(long)tagId andBdCode:(NSArray *)codeArray;


/**
 *  重新加载新闻(刷新)
 */
- (void)reloadNews;

/**
 *  加载更多的新闻
 */
- (void)loadMoreNews;

@end
