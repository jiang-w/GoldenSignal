//
//  BDCoreService.h
//  yicai_iso
//
//  Created by Frank on 14-7-31.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDQuery.h"

@interface BDCoreService : NSObject

/**
 *  同步请求数据源分页数据
 *
 *  @param objId      数据源ID
 *  @param parameters 数据源内部参数
 *  @param query      数据源查询条件
 *  @param pageSize   每页记录数
 *  @param pageIndex  页索引
 *
 *  @return 返回数据
 */
- (NSArray *) syncRequestDatasourceService:(int)objId parameters:(NSDictionary *)parameters query:(BDQuery *)query pageSize:(int)pageSize pageIndex:(int)pageIndex recordCount:(int *)recordCount pageCount:(int *)pageCount;


/**
 *  同步请求数据源数据
 *
 *  @param objId      数据源ID
 *  @param parameters 数据源内部参数
 *  @param query      数据源查询条件
 *
 *  @return 返回数据
 */
- (NSArray *)syncRequestDatasourceService:(int)objId parameters:(NSDictionary *)parameters query:(BDQuery *)query;


/**
 *  将服务返回的Json数据解析成数组
 *
 *  @param data 远程请求返回的数据
 *
 *  @return 返回数组对象
 */
- (NSArray *)dataConvertToNSArray:(NSData *)data;


/**
 *  将json日期格式字符串转换为NSDate类型
 *
 */
- (NSDate *)deserializeJsonDateString:(NSString *)jsonDateString;

@end
