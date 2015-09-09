//
//  BDQuotationService.h
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface BDQuotationService : NSObject

+ (instancetype) sharedInstance;

- (void)subscribeScalarWithCode:(NSString *)code indicaters:(NSArray *)names;

- (void)unsubscribeScalarWithCode:(NSString *)code indicaters:(NSArray *)names;

- (void)subscribeSerialsWithCode:(NSString *)code indicateName:(NSString *)name beginDate:(int)date beginTime:(int)time numberType:(int)type number:(int)number;

- (id)getCurrentIndicateWithCode:(NSString *)code andName:(NSString *)name;

- (void)connect;

- (void)disconnect;

- (BOOL)isConnected;

/**
 *  获取指标signal
 *
 *  @param code     证券编码
 *  @param name     指标名称
 */
- (RACSignal *)scalarSignalWithCode:(NSString *)code andIndicater:(NSString *)name;

/**
 *  获取历史K线signal
 *
 *  @param code     证券编码
 *  @param type     K线类型（日K、周K、月K）
 *  @param number   K线的条数
 */
- (RACSignal *)kLineSignalWithCode:(NSString *)code forType:(KLineType)type andNumber:(NSInteger)number;

/**
 *  获取历史走势线signal
 *
 *  @param code     证券编码
 *  @param days     天数（一日、五日）
 *  @param interval 间隔分钟数（一分钟、五分钟）
 */
- (RACSignal *)trendLineWithCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval;

@end
