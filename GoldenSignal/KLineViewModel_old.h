//
//  LiteKLineViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLineViewModel_old : NSObject
{
    int _requestNumber;
}

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, strong, readonly)NSString *code;

/**
 *  K线数组
 */
@property(nonatomic, strong, readonly)NSMutableArray *lines;

/**
 *  是否已经完成初始化(加载完历史走势数据)
 */
@property(nonatomic, assign, readonly)BOOL initialized;

/**
 *  K线的类型
 */
@property(nonatomic, assign, readonly)KLineType type;

/**
 *  价格区间
 */
@property(nonatomic, assign, readonly)PriceRange priceRange;

/**
 *  最大交易量
 */
@property(nonatomic, assign, readonly)unsigned int maxVolume;


- (id)initWithCode:(NSString *)code;

- (void)loadKLineWithType:(KLineType)type andNumber:(int)number;

- (float)calcAvgPriceForDate:(int)date andMA:(int)value;

@end
