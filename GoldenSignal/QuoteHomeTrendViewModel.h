//
//  IdxTrendViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuoteHomeTrendViewModel : NSObject

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
@property(nonatomic, readonly) double PrevClose;

/**
 *  开盘价
 */
@property(nonatomic, readonly) double Open;

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
 *  成交量（手）
 */
@property(nonatomic, readonly) unsigned long Volume;


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
