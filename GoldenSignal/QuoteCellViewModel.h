//
//  QuoteCellViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuoteCellViewModel : NSObject

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
 *  最新报价
 */
@property(nonatomic, readonly) float Now;

/**
 *  涨跌幅
 */
@property(nonatomic, readonly) float ChangeRange;

/**
 *  现量
 */
@property(nonatomic, readonly) int VolumeSpread;

/**
 *  总股本（股）
 */
@property(nonatomic, readonly) double TtlShr;

/**
 *  总市值（亿）
 */
@property(nonatomic, readonly) double TtlAmount;

/**
 *  市盈率(PE)
 */
@property(nonatomic, readonly) float PEttm;

/**
 *  新闻事件日期
 */
@property(nonatomic, readonly) int NewsRatingDate;

/**
 *  新闻事件评级
 */
@property(nonatomic, readonly) int NewsRatingLevel;

/**
 *  新闻事件分类
 */
@property(nonatomic, readonly) NSString *NewsRatingName;


- (void)subscribeQuotationScalarWithCode:(NSString *)code;

@end
