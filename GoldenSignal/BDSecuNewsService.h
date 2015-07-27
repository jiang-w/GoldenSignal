//
//  BDBulletinService.h
//  CBNAPP
//
//  Created by Frank on 14/12/16.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSecuNewsService : NSObject

/**
 *  获取个股资讯列表
 *
 *  @param code         证券编码
 *  @param type         资讯类型(新闻、研报、公告)
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getListWithSecuCode:(NSString *)code type:(NewsType)type quantity:(NSUInteger)quantity;

@end
