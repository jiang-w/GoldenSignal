//
//  BDImportService.h
//  GoldenSignal
//
//  Created by CBD on 7/6/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDNewStockModel.h"

@interface BDImportService : NSObject


/**
*  获取要闻各个页面的数据
*  @param pageId    不同页面对应的id
*  @param lastId    列表最后一条的id
*  @param cellNuber 列数 一般为10条
*  @return 返回的数据 存入数组中
*/
- (NSMutableArray *)getImportNewsListRequestDataWithPageId:(int)pageId lastCellId:(long)lastId quantity:(int)cellCount;


/**
 *  获取要闻 策略页面的数据
 *  @param pageId    不同页面对应的id
 *  @param cellCount 列数 一般为10条
 *  @param index     次数 第几次
 *  @return 返回的数据 存入数组中
 */
- (NSMutableArray *)getImportNewsStrategyRequestDataWithPageId:(int)pageId cellCount:(int)cellCount timeNumber:(int)index;



/**
 *  获取要闻 新股页面的数据
 *  @param pageId    不同页面对应的id
 *  @param lastId    列表最后一条的id
 *  @param cellNumber 列数 一般为10条
 *  @return 返回的数据 存入数组中
 */
- (NSMutableArray *)getImportNewStockRequestDataWithPageId:(int)pageId lastCellId:(long)lastId quantity:(int)cellNumber;


/**
 *  获取要闻 新股 子页面 详细信息
 *
 *  @param connectId 连接的Id 即 股票代码
 *  @param pageId    页面数据源Id （1591）
 *
 *  @return Model
 */
- (BDNewStockModel *)getImportNewsStockDetailWithId:(long)connectId andPageId:(int)pageId;


@end
