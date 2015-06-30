//
//  BDTradingDayService.m
//  GoldenSignal
//
//  Created by Frank on 15/6/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDTradingDayService.h"
#import "BDDatabaseAccess.h"

#define TABLENAME @"TRADINGDAY"
#define DATE_FORMAT @"yyyy-MM-dd"

@implementation BDTradingDayService

+ (NSArray *)getTradingDaysUntilNowForDays:(NSUInteger)days {
    NSMutableArray *arr = [NSMutableArray array];
    BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:SQLITE_BASE_DATABASE];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = DATE_FORMAT;
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate new]];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where norm_day <= '%@' and is_trd_day = 1 order by norm_day desc limit 0,%lu", TABLENAME, dateStr, days];
    FMResultSet *rs = [dbAccess queryTable:sql];
    while ([rs next]){
        NSString *date = [rs stringForColumn:@"Trd_day"];
        [arr addObject:date];
    }
    return arr;
}

+ (NSArray *)getTradingDaysToDate:(NSString *)date forDays:(NSUInteger)days {
    NSMutableArray *arr = [NSMutableArray array];
    BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:SQLITE_BASE_DATABASE];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where norm_day <= '%@' and is_trd_day = 1 order by norm_day desc limit 0,%lu", TABLENAME, date, days];
    FMResultSet *rs = [dbAccess queryTable:sql];
    while ([rs next]){
        NSString *date = [rs stringForColumn:@"Trd_day"];
        [arr addObject:date];
    }
    return arr;
}

@end
