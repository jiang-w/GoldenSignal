//
//  KLineChartViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLineViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, strong, readonly) NSString *code;

/**
 *  K线数组
 */
@property(nonatomic, strong, readonly) NSArray *lines;

/**
 *  K线的类型（日K、周K、月K）
 */
@property(nonatomic, assign, readonly) KLineType type;

/**
 *  K线呈现的根数
 */
@property(nonatomic, assign, readonly) NSUInteger number;

/**
 *  价格区间
 */
@property(nonatomic, assign, readonly) PriceRange priceRange;

/**
 *  最大交易量
 */
@property(nonatomic, assign, readonly) unsigned long maxVolume;


- (instancetype)initWithCode:(NSString *)code kLineType:(KLineType)type andNumber:(NSUInteger)number;

- (double)calcAvgPriceForDate:(NSUInteger)date andMA:(NSUInteger)value;

@end
