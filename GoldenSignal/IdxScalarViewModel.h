//
//  IdxScalarViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdxScalarViewModel : NSObject

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
 *  涨跌
 */
@property(nonatomic, readonly) double Change;

/**
 *  涨跌幅
 */
@property(nonatomic, readonly) double ChangeRange;

/**
 *  振幅
 */
@property(nonatomic, readonly) double Amplitude;

/**
 *  日成交额(金额)
 */
@property(nonatomic, readonly) double Amount;

/**
 *  日成交量(总手)
 */
@property(nonatomic, readonly) unsigned long Volume;

/**
 *  现量
 */
@property(nonatomic, readonly) unsigned long VolumeSpread;

/**
 *  上涨家数
 */
@property(nonatomic, readonly) unsigned int UpCount;

/**
 *  下跌家数
 */
@property(nonatomic, readonly) unsigned int DownCount;


- (id)initWithCode:(NSString *)code;

@end
