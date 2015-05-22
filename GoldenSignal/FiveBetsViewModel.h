//
//  BDFiveBets.h
//  CBNAPP
//
//  Created by Frank on 14/11/20.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FiveBetsViewModel : NSObject

@property(nonatomic, strong, readonly) NSString *code;

@property(nonatomic, assign)float prevClose;

/* 买1价 - 买5价 */
@property(nonatomic, assign)float bidPrice1;
@property(nonatomic, assign)float bidPrice2;
@property(nonatomic, assign)float bidPrice3;
@property(nonatomic, assign)float bidPrice4;
@property(nonatomic, assign)float bidPrice5;

/* 买1量 - 买5量 */
@property(nonatomic, assign)UInt64 bidVolume1;
@property(nonatomic, assign)UInt64 bidVolume2;
@property(nonatomic, assign)UInt64 bidVolume3;
@property(nonatomic, assign)UInt64 bidVolume4;
@property(nonatomic, assign)UInt64 bidVolume5;

/* 卖1价 - 卖5价 */
@property(nonatomic, assign)float askPrice1;
@property(nonatomic, assign)float askPrice2;
@property(nonatomic, assign)float askPrice3;
@property(nonatomic, assign)float askPrice4;
@property(nonatomic, assign)float askPrice5;

/* 卖1量 - 卖5量 */
@property(nonatomic, assign)UInt64 askVolume1;
@property(nonatomic, assign)UInt64 askVolume2;
@property(nonatomic, assign)UInt64 askVolume3;
@property(nonatomic, assign)UInt64 askVolume4;
@property(nonatomic, assign)UInt64 askVolume5;

- (id)initWithCode:(NSString *)code;

@end
