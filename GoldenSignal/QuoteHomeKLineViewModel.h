//
//  IdxKLineViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuoteHomeKLineViewModel : NSObject

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


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
