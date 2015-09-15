//
//  StkScalarViewModel.h
//  GoldenSignal
//
//  Created by Frank on 14/10/27.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StkScalarViewModel : NSObject

/**
 *  代码
 */
@property(nonatomic, readonly) NSString *Code;

/**
 *  前收价
 */
@property(nonatomic, readonly) double PrevClose;

/**
 *  开盘价
 */
@property(nonatomic, readonly) double Open;

/**
 *  最高价
 */
@property(nonatomic, readonly) double High;

/**
 *  最低价
 */
@property(nonatomic, readonly) double Low;

/**
 *  最新报价
 */
@property(nonatomic, readonly) double Now;

/**
 *  日成交额(金额)
 */
@property(nonatomic, readonly) double Amount;

/**
 *  日成交量(总手)
 */
@property(nonatomic, readonly) unsigned long Volume;

/**
 *  换手率
 */
@property(nonatomic, readonly) double ChangeHandsRate;

/**
 *  量比
 */
@property(nonatomic, readonly) double VolRatio;

/**
 *  现量
 */
@property(nonatomic, readonly) unsigned long VolumeSpread;

/**
 *  总股本（股）
 */
@property(nonatomic, readonly) double TtlShr;

/**
 *  总市值（亿）
 */
@property(nonatomic, readonly) double TtlAmount;

/**
 *  无限售条件流通股份合计
 */
@property(nonatomic, readonly) double TtlShrNtlc;

/**
 *  流通市值（亿）
 */
@property(nonatomic, readonly) double TtlAmountNtlc;

/**
 *  市盈率
 */
@property(nonatomic, readonly) double PEttm;

/**
 *  EPS
 */
@property(nonatomic, readonly) double Eps;


- (id)initWithCode:(NSString *)code;

@end
