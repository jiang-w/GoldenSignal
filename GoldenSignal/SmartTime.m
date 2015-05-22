//
//  BDTime.m
//  CBNAPP
//
//  Created by Frank on 14/12/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "SmartTime.h"

@implementation SmartTime

- (id)initWithHour:(NSInteger)hour andMinute:(NSInteger)minute andSecond:(NSInteger)second {
    self = [super init];
    if (self) {
        self.hour = hour;
        self.minute = minute;
        self.second = second;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.hour = 0;
        self.minute = 0;
        self.second = 0;
    }
    return self;
}

- (void)setHour:(NSInteger)hour {
    if (hour >= 0 && hour < 24) {
        _hour = hour;
    }
    else {
        NSException *exception = [NSException exceptionWithName:@"属性赋值不合法" reason:@"hour必须大于等于0小于24" userInfo:nil];
        @throw exception;
    }
}

- (void)setMinute:(NSInteger)minute {
    if (minute >= 0 && minute < 60) {
        _minute = minute;
    }
    else {
        NSException *exception = [NSException exceptionWithName:@"属性赋值不合法" reason:@"minute必须大于等于0小于60" userInfo:nil];
        @throw exception;
    }
}

- (void)setSecond:(NSInteger)second {
    if (second >=0 && second < 60) {
        _second = second;
    }
    else {
        NSException *exception = [NSException exceptionWithName:@"属性赋值不合法" reason:@"second必须大于等于0小于60" userInfo:nil];
        @throw exception;
    }
}

- (SmartTime *)addHours:(NSInteger)value {
    NSInteger hour = (_hour + value) % 24;
    return [[SmartTime alloc] initWithHour:hour andMinute:_minute andSecond:_second];
}

- (SmartTime *)addMinutes:(NSInteger)value {
    NSInteger hour = (_hour + (_minute + value) / 60) % 24;
    NSInteger minute = (_minute + value) % 60;
    return [[SmartTime alloc] initWithHour:hour andMinute:minute andSecond:_second];
}

- (SmartTime *)addSeconds:(NSInteger)value {
    NSInteger second = (_second + value) % 60;
    NSInteger minute = (_minute + (_second + value) / 60) % 60;
    NSInteger hour = (_hour + (_minute + (_second + value) / 60) / 60) % 24;
    return [[SmartTime alloc] initWithHour:hour andMinute:minute andSecond:second];
}

+ (SmartTime *)time {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    NSInteger second = [dateComponent second];
    return [[SmartTime alloc] initWithHour:hour andMinute:minute andSecond:second];
}

- (NSComparisonResult)compare:(SmartTime *)time {
    if (self.hour > time.hour) {
        return NSOrderedDescending;
    }
    else if (self.hour < time.hour) {
        return NSOrderedAscending;
    }
    if (self.minute > time.minute) {
        return NSOrderedDescending;
    }
    else if (self.minute < time.minute) {
        return NSOrderedAscending;
    }
    if (self.second > time.second) {
        return NSOrderedDescending;
    }
    else if (self.second < time.second) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

@end
