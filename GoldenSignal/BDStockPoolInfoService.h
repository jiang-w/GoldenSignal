//
//  BDStockPoolInfoService.h
//  GoldenSignal
//
//  Created by Frank on 15/6/18.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDStockPoolInfoService : NSObject

/**
 *  获取自选股公告列表（返回BDBulletin类型数组）
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSArray *)getBulletinListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

/**
 *  获取自选股提示列表（返回BDPrompt类型数组）
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSArray *)getPromptListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

/**
 *  获取自选股研报列表（返回BDReport类型数组）
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSArray *)getReportListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

/**
 *  获取自选股新闻列表（返回BDNews类型数组）
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSArray *)getNewsListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

/**
 *  获取自选股业绩列表（返回BDPrompt类型数组）
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSArray *)getPerformanceListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

@end
