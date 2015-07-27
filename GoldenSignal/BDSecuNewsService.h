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
 *  根据证券编码加载公告列表
 *
 *  @param code         证券编码
 *  @param sn           
 *  @param quantity     返回公告的数量
 */
- (NSArray *)getBulletinBySecuCode:(NSString *)code andSN:(long)sn andQuantity:(int)quantity;

/**
 *  根据证券编码加载研报列表
 *
 *  @param code         证券编码
 *  @param sn
 *  @param quantity     返回研报的数量
 */
- (NSArray *)getReportBySecuCode:(NSString *)code andSN:(long)sn andQuantity:(int)quantity;

/**
 *  根据证券编码加载新闻列表
 *
 *  @param code         证券编码
 *  @param sn           最新一条新闻ID
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getNewsEventBySecuCode:(NSString *)code andSN:(long)sn andQuantity:(int)quantity;

/**
 *  获取个股资讯新闻列表
 *
 *  @param code         证券编码
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getNewsListBySecuCode:(NSString *)code andQuantity:(int)quantity;

/**
 *  获取个股资讯公告列表
 *
 *  @param code         证券编码
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getBulletinListBySecuCode:(NSString *)code andQuantity:(int)quantity;

/**
 *  获取个股资讯研报列表
 *
 *  @param code         证券编码
 *  @param quantity     返回新闻的数量
 */
- (NSArray *)getReportListBySecuCode:(NSString *)code andQuantity:(int)quantity;

@end
