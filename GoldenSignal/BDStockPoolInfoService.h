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
 *  获取自选股提示列表（返回BDPrompt类型数组）   提示1
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSMutableArray *)getPromptListBySecuCodes:(NSMutableArray *)codes pageIndex:(NSUInteger)index andPageSize:(NSUInteger)size;

/**
 *  获取自选股公告列表（返回BDBulletin类型数组） 公告2
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSMutableArray *)getBulletinListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

/**
 *  获取自选股研报列表（返回BDReport类型数组）   研报3
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSMutableArray *)getReportListBySecuCode:(NSArray *)codes pageIndex:(NSUInteger)index andPageSize:(NSUInteger)size;

/**
 *  获取自选股新闻列表（返回BDNews类型数组）     新闻4
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSMutableArray *)getNewsListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;

/**
 *  获取自选股业绩列表（返回BDPrompt类型数组）   业绩5
 *
 *  @param codes         证券编码列表
 *  @param quantity      返回数量
 */
- (NSMutableArray *)getPerformanceListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity;



/**
 *  获取自选股 公告 的子页面 详细数据      2
 *
 *  @param connectId 每个cell对应的id（自己找下）
 *
 *  @return 返回一个model
 */
- (BDBulletin *)getBulletinDetailById:(long)connectId;


@end
