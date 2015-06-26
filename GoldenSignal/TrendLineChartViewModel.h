//
//  TrendLineChartViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendLineChartViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, copy, readonly) NSString *code;

/**
 *  前收价
 */
@property(nonatomic, assign, readonly) double prevClose;

/**
 *  走势线
 */
@property(nonatomic, retain, readonly) NSMutableArray *lines;

/**
 *  价格区间
 */
@property(nonatomic, assign, readonly)PriceRange priceRange;

/**
 *  包含哪些日期的走势线
 */
@property(nonatomic, retain, readonly)NSArray *dates;


- (void)loadDataWithSecuCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval;

- (CGPoint)getPointInFrame:(CGRect)frame withSerialNumber:(int)number andPrice:(float)price;
- (int)getSerialNumberWithTime:(int)time;
- (int)getTimeWithSerialNumber:(int)number;

@end
