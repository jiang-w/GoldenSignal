//
//  RankingListCellViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/7/9.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RankingListCellViewModel : NSObject

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
@property(nonatomic, readonly) double Change;

/**
 *  涨跌幅
 */
@property(nonatomic, readonly) double ChangeRange;


- (void)loadDataWithCode:(NSString *)code;

@end
