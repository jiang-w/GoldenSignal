//
//  IdxQuoteViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdxQuoteViewModel : NSObject

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
 *  振幅
 */
@property(nonatomic, readonly) float Amplitude;

/**
 *  日成交额(金额)
 */
@property(nonatomic, readonly) double Amount;

/**
 *  日成交量(总手)
 */
@property(nonatomic, readonly) long Volume;

/**
 *  现量
 */
@property(nonatomic, readonly) long VolumeSpread;

/**
 *  上涨家数
 */
@property(nonatomic, readonly) int UpCount;

/**
 *  下跌家数
 */
@property(nonatomic, readonly) int DownCount;


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
