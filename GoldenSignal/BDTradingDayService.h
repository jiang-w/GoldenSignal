//
//  BDTradingDayService.h
//  GoldenSignal
//
//  Created by Frank on 15/6/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDTradingDayService : NSObject

+ (NSArray *)getTradingDaysUntilNowForDays:(NSUInteger)days;

@end
