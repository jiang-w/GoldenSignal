//
//  BDNewsService.h
//  CBNAPP
//
//  Created by Frank on 14/11/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNewsEventService : NSObject

/**
 *  根据ID获取新闻事件详情
 *
 *  @param innerId     内部ID
 */
- (BDNewsEventDetail *)getNewsEventDetailById:(long)innerId;

/**
 *  根据证券编码加载新闻列表
 *
 *  @param codes        证券编码列表
 *  @param tagId        新闻标签ID
 *  @param lastId       最新一条新闻ID
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getNewsEventListBySecuCodes:(NSArray *)codes tagId:(long)tagId lastId:(long)lastId quantity:(int)quantity;

@end
