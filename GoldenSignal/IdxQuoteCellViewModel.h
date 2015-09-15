//
//  IdxQuoteCellViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/8.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLineViewModel.h"

@interface IdxQuoteCellViewModel : NSObject

/**
 *  代码
 */
@property(nonatomic, readonly) NSString *Code;

/**
 *  代码
 */
@property(nonatomic, readonly) NSString *TrdCode;

/**
 *  简称
 */
@property(nonatomic, readonly) NSString *Name;

/**
 *  前收价
 */
@property(nonatomic, readonly) double PrevClose;

/**
 *  最新报价
 */
@property(nonatomic, readonly) double Now;

/**
 *  涨跌幅
 */
@property(nonatomic, readonly) double ChangeRange;

/**
 *  日成交量
 */
@property(nonatomic, readonly) unsigned long Volume;

/**
 *  日成交额(金额)
 */
@property(nonatomic, readonly) double Amount;

/**
 *  上涨家数
 */
@property(nonatomic, readonly) unsigned int UpCount;

/**
 *  平盘家数
 */
@property(nonatomic, readonly) unsigned int SameCount;

/**
 *  下跌家数
 */
@property(nonatomic, readonly) unsigned int DownCount;


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
