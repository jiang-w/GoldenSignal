//
//  IdxTrendViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdxTrendViewModel : NSObject

/**
 *  代码
 */
@property(nonatomic, readonly)NSString *Code;

/**
 *  简称
 */
@property(nonatomic, readonly)NSString *Name;

/**
 *  前收价
 */
@property(nonatomic, readonly) float PrevClose;

/**
 *  开盘价
 */
@property(nonatomic, readonly) float Open;

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
 *  总股本（股）
 */
@property(nonatomic, readonly) double TtlShr;

/**
 *  总市值（亿）
 */
@property(nonatomic, readonly) double TtlAmount;


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
