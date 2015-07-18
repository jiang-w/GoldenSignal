//
//  NSDate+Utility.m
//  CBNAPP
//
//  Created by Frank on 14-8-21.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "NSDate+Utility.h"

@implementation NSDate (Utility)

- (NSString *)toString:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

- (NSDate *)addDays:(int)value
{
    return [self dateByAddingTimeInterval:(value * 24 * 60 * 60)];
}

- (NSInteger)getYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compt = [calendar components:NSCalendarUnitYear fromDate:self];
    return [compt year];
}

- (NSInteger)getMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compt = [calendar components:NSCalendarUnitMonth fromDate:self];
    return [compt month];
}

- (NSInteger)getDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compt = [calendar components:NSCalendarUnitDay fromDate:self];
    return [compt day];
}

- (BOOL)isSameDay:(NSDate *)date {
    if (date == nil) return NO;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
    NSDate *myDate = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    return [myDate isEqualToDate:otherDate];
}

@end
