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
 *
 *  @return 证券编码数组
 */
- (NSArray *)getSecuCodesBySectId:(long)sectId SortByIndicateName:(NSString *)name;

@end
