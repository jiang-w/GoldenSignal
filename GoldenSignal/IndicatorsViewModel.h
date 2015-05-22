//
//  BDQuotation.h
//  CBNAPP
//
//  Created by Frank on 14/10/27.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndicatorsViewModel : NSObject

/**
 *  代码
 */
@property(nonatomic, readonly) NSString *Code;

/**
 *  前收价
 */
@property(nonatomic, readonly) float PrevClose;

/**
 *  开盘价
 */
@property(nonatomic, readonly) float Open;

/**
 *  最高价
 */
@property(nonatomic, readonly) float High;

/**
 *  最低价
 */
@property(nonatomic, readonly) float Low;

/**
 *  最新报价
 */
@property(nonatomic, readonly) float Now;

/**
 *  涨跌
 */
@property(nonatomic, readonly) float Change;

/**
 *  涨跌幅
 */
@property(nonatomic, readonly) float ChangeRange;

/**
 *  日成交额(金额)
 */
@property(nonatomic, readonly) double Amount;

/**
 *  日成交量(总手)
 */
@property(nonatomic, readonly) int Volume;

/**
 *  换手率
 */
@property(nonatomic, readonly) float ChangeHandsRate;

/**
 *  量比
 */
@property(nonatomic, readonly) float VolRatio;

/**
 *  现量
 */
@property(nonatomic, readonly) int VolumeSpread;

/**
 *  总股本（股）
 */
@property(nonatomic, readonly) float TtlShr;

/**
 *  总市值（亿）
 */
@property(nonatomic, readonly) float TtlAmount;

/**
 *  无限售条件流通股份合计
 */
@property(nonatomic, readonly) float TtlShrNtlc;

/**
 *  流通市值（亿）
 */
@property(nonatomic, readonly) float TtlAmountNtlc;

/**
 *  市盈率
 */
@property(nonatomic, readonly) float PEttm;

/**
 *  EPS
 */
@property(nonatomic, readonly) float Eps;


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
