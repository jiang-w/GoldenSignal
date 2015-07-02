//
//  BDTrendViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/2/5.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendLineViewModel_old : NSObject
{
    int _requestDays;
}

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, copy, readonly) NSString *code;

/**
 *  前收价
 */
@property(nonatomic, assign, readonly) float prevClose;

/**
 *  是否已经完成初始化(加载完历史走势数据)
 */
@property(nonatomic, assign, readonly) BOOL initialized;

/**
 *  包含哪些日期的走势线
 */
@property(nonatomic, retain, readonly) NSArray *dates;

/**
 *  间隔的分钟数
 */
@property(nonatomic, assign, readonly) int interval;

/**
 *  走势线
 */
@property(nonatomic, retain, readonly) NSMutableArray *lines;

/**
 *  价格区间
 */
@property(nonatomic, assign, readonly) PriceRange priceRange;

/**
 *  最大交易量
 */
@property(nonatomic, assign, readonly) unsigned long maxVolume;


- (id)initWithCode:(NSString *)code;

- (void)loadTrendLineForDays:(int)days andInterval:(int)interval;

- (CGPoint)getPointInFrame:(CGRect)frame WithSerialNumber:(int)number andPrice:(float)price;

- (int)getSerialNumberWithTime:(int)time;

- (int)getTimeWithSerialNumber:(int)number;

@end
