//
//  BDNewsService.h
//  CBNAPP
//
//  Created by Frank on 14/11/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNewsService : NSObject

/**
 *  根据ID获取新闻
 *
 *  @param newsId       新闻ID
 */
- (BDNews *)getNewsById:(long)newsId;

/**
 *  根据标签加载新闻列表
 *
 *  @param tagId        新闻标签ID
 *  @param lastNewsId   最新一条新闻ID
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getNewsEventByTagId:(long)tagId lastId:(long)lastNewsId quantity:(int)quantity;

/**
 *  根据证券编码加载新闻列表
 *
 *  @param code         证券编码
 *  @param lastNewsId   最新一条新闻ID
 *  @param quantity     返回新闻的数量
 */
//- (NSArray *)getNewsEventBySecuCode:(NSString *)code lastId:(long)lastNewsId quantity:(int)quantity;

@end
