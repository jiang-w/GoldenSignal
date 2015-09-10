//
//  TrendLineChartViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendLineViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, strong, readonly) NSString *code;

/**
 *  前收价
 */
@property(nonatomic, assign, readonly) double prevClose;

/**
 *  走势线
 */
@property(nonatomic, strong) NSMutableArray *lines;

/**
 *  间隔的分钟数
 */
@property(nonatomic, assign, readonly) NSUInteger interval;

/**
 *  几个交易日
 */
@property(nonatomic, assign, readonly) NSUInteger days;

/**
 *  价格区间
 */
@property(nonatomic, assign, readonly) PriceRange priceRange;

/**
 *  最大交易量
 */
@property(nonatomic, assign, readonly) unsigned long maxVolume;

/**
 *  包含哪些日期的走势线
 */
@property(nonatomic, strong, readonly) NSArray *tradingDays;


- (instancetype)initWithCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval;

- (NSArray *)getPricePointInFrame:(CGRect)frame forTradingDay:(NSString *)date;

- (NSArray *)getAvgPricePointInFrame:(CGRect)frame forTradingDay:(NSString *)date;

- (NSArray *)getVolumePointInFrame:(CGRect)frame forTradingDay:(NSString *)date;


@end
