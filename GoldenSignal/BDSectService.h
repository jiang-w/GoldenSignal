//
//  BDSectService.h
//  GoldenSignal
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSectService : NSObject

/**
 *  根据类别获取板块信息
 *
 *  @param typCode       类别代码（nil值则取全部板块）
 *
 *  @return BDSectInfo类型数组
 */
- (NSArray *)getSectInfoByTypeCode:(NSString *)typCode;


/**
 *  获取板块成分
 *
 *  @param sectId        板块ID
 *  @param name          用于排序的指标名称
 *  @param asc           是否为升序排列
 *
 *  @return 证券编码数组
 */
- (NSArray *)getSecuCodesBySectId:(long)sectId sortByIndicateName:(NSString *)name ascending:(BOOL)asc;

/**
 *  获取板块成分
 *
 *  @param sectId        板块ID
 *  @param codeArray     自定义证券编码（字符串数组）
 *  @param name          用于排序的指标名称
 *  @param asc           是否为升序排列
 *
 *  @return 证券编码数组
 */
- (NSArray *)getSecuCodesBySectId:(long)sectId andCodes:(NSArray *)codeArray sortByIndicateName:(NSString *)name ascending:(BOOL)asc;

/**
 *  获取指数所属的板块ID
 *
 *  @param code          指数的BD_CODE
 *
 *  @return 板块ID
 */
- (NSUInteger)getSectIdByIndexCode:(NSString *)code;

@end
