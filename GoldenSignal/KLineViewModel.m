//
//  KLineViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "KLineViewModel.h"
#import "BDQuotationService.h"

#define ExtraLines 20
#define IndicaterNames @[@"Date", @"Time", @"Now", @"Open", @"High", @"Low", @"Volume"]

@interface KLineViewModel()

@property(nonatomic, assign) BOOL initialized;  // 是否加载完历史数据
@property(nonatomic, assign) KLineType type;    // K线的类型（日K、周K、月K）
@property(nonatomic, assign) NSUInteger number; // K线数量

@end

@implementation KLineViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _propertyUpdateQueue = dispatch_queue_create("KLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        _lines = [NSMutableArray array];
        self.initialized = NO;
        self.type = KLINE_DAY;
        self.number = 60;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}


#pragma mark - Property

// 价格区间
- (PriceRange)priceRange {
    double maxPrice = 0;
    double minPrice = 0;
    NSRange range = _lines.count > _number ? NSMakeRange(_lines.count - _number, _number) : NSMakeRange(0, _lines.count);
    NSArray *lines = [_lines subarrayWithRange:range];
    for (BDKLine *kLine in lines) {
        if (kLine.high > maxPrice) {
            maxPrice = kLine.high;
        }
        if (minPrice == 0 || kLine.low < minPrice) {
            minPrice = kLine.low;
        }
    }
    return (PriceRange){minPrice, maxPrice};
}

// 最大交易量
- (unsigned long)maxVolume {
    unsigned long max = 0;
    NSRange range = _lines.count > _number ? NSMakeRange(_lines.count - _number, _number) : NSMakeRange(0, _lines.count);
    NSArray *lines = [_lines subarrayWithRange:range];
    for (BDKLine *kLine in lines) {
        if (kLine.volume > max) {
            max = kLine.volume;
        }
    }
    return max;
}


#pragma mark Method

- (void)loadDataWithSecuCode:(NSString *)code forType:(KLineType)type andNumber:(NSUInteger)number {
    if (code) {
        if (![_code isEqualToString:code]) {
            if (_code) {
                [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
            }
            _initialized = NO;
            _code = [code copy];
            [_service subscribeScalarWithCode:_code indicaters:IndicaterNames];
        }
        else {
            if (_type != type || _number != number) {
                _initialized = NO;
            }
        }
        
        if (!_initialized) {
            _type = type;
            _number = number;
            [_lines removeAllObjects];
            [_service subscribeSerialsWithCode:_code indicateName:@"KLine" beginDate:0 beginTime:0 numberType:(int)_type number:(int)_number + ExtraLines];
        }
    }
}

// 计算均价
- (double)calcAvgPriceForDate:(NSUInteger)date andMA:(NSUInteger)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"date <= %lu", date]];
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[self.lines filteredArrayUsingPredicate:predicate]];
    [lines sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    if (lines.count >= value) {
        NSRange range = NSMakeRange(0, value);
        NSArray *subArray = [lines subarrayWithRange:range];
        double totalPrice = 0;
        for (BDKLine *line in subArray) {
            totalPrice += line.close;
        }
        return totalPrice / subArray.count;
    }
    else {
        return 0;
    }
}


#pragma mark Subscribe

- (void)reconnection {
    self.initialized = NO;
    [self loadDataWithSecuCode:self.code forType:self.type andNumber:self.number + ExtraLines];
}

- (NSMutableArray *)paraseTrendLines:(NSArray *)data {
    NSMutableArray *arr = [NSMutableArray array];
    @try {
        for (NSDictionary *item in data) {
            BDKLine *kLine = [[BDKLine alloc] init];
            kLine.date = [[item objectForKey:@"Date"] unsignedIntValue];
            kLine.high = [[item objectForKey:@"High"] doubleValue];
            kLine.low = [[item objectForKey:@"Low"] doubleValue];
            kLine.open = [[item objectForKey:@"Open"] doubleValue];
            kLine.close = [[item objectForKey:@"Now"] doubleValue];
            kLine.volume = [[item objectForKey:@"Volume"] unsignedLongValue];
            [arr addObject:kLine];
        }
        [arr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: 初始化K线数据异常 %@", [exception reason]);
    }
    return arr;
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if (self.code && [self.code isEqualToString:code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            if ([indicateName isEqualToString:@"KLine"] && !self.initialized) {
                int number = [dic[@"numberFromBegin"] intValue];
                KLineType type = (KLineType)[dic[@"numberType"] intValue];
                
                if (self.type == type && self.number + ExtraLines == number) {
                    _lines = [self paraseTrendLines:[value objectForKey:@"KLine"]];
                    [self updateKLine];
                    self.initialized = YES;
                }
            }
            
            if (self.initialized) {
                if ([indicateName isEqualToString:@"Time"]) {
                    [self updateKLine];
                }
            }
        });
    }
}

// 更新K线数据
- (void)updateKLine {
    @try {
        unsigned int date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] unsignedIntValue];
        double high = [[_service getCurrentIndicateWithCode:self.code andName:@"High"] doubleValue];
        double open = [[_service getCurrentIndicateWithCode:self.code andName:@"Open"] doubleValue];
        double low = [[_service getCurrentIndicateWithCode:self.code andName:@"Low"] doubleValue];
        double close = [[_service getCurrentIndicateWithCode:self.code andName:@"Now"] doubleValue];
        unsigned long volume = [[_service getCurrentIndicateWithCode:self.code andName:@"Volume"] unsignedLongValue];
        
        BDKLine *lastLine = [self.lines lastObject];
        switch (self.type) {
            case KLINE_DAY:
                if (lastLine && lastLine.date == date) {
                    lastLine.high = high;
                    lastLine.open = open;
                    lastLine.low = low;
                    lastLine.close = close;
                    lastLine.volume = volume;
                }
                else {
                    BDKLine *newLine = [[BDKLine alloc] init];
                    newLine.date = date;
                    newLine.high = high;
                    newLine.open = open;
                    newLine.low = low;
                    newLine.close = close;
                    newLine.volume = volume;
                    [self.lines addObject:newLine];
                }
                break;
            case KLINE_WEEK:
                if (lastLine && [self inSameWeekWithDate:lastLine.date andDate:date]) {
                    if (high > lastLine.high) {
                        lastLine.high = high;
                    }
                    if (low < lastLine.low) {
                        lastLine.low = low;
                    }
                    lastLine.close = close;
                    lastLine.date = date;
                }
                else {
                    BDKLine *newLine = [[BDKLine alloc] init];
                    newLine.date = date;
                    newLine.high = high;
                    newLine.open = open;
                    newLine.low = low;
                    newLine.close = close;
                    newLine.volume = volume;
                    [self.lines addObject:newLine];
                }
            case KLINE_MONTH:
                if (lastLine && [self inSameMonthWithDate:lastLine.date andDate:date]) {
                    if (high > lastLine.high) {
                        lastLine.high = high;
                    }
                    if (low < lastLine.low) {
                        lastLine.low = low;
                    }
                    lastLine.close = close;
                    lastLine.date = date;
                }
                else {
                    BDKLine *newLine = [[BDKLine alloc] init];
                    newLine.date = date;
                    newLine.high = high;
                    newLine.open = open;
                    newLine.low = low;
                    newLine.close = close;
                    newLine.volume = volume;
                    [self.lines addObject:newLine];
                }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: 更新K线数据异常 %@", [exception reason]);
    }
    @finally {
        [self setValue:self.lines forKey:@"lines"];  // kvo
    }
}

- (BOOL)inSameWeekWithDate:(unsigned int)one andDate:(unsigned int)another {
    BOOL result = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *oneDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%u", one]];
    NSDate *anotherDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%u", another]];
 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 2;
    int weekday1 = (int)[calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:oneDate];
    int weekday2 = (int)[calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:anotherDate];
    result = [[oneDate addDays:-(weekday1 - 1)] isEqualToDate:[anotherDate addDays:-(weekday2 - 1)]];
    return result;
}

- (BOOL)inSameMonthWithDate:(unsigned int)one andDate:(unsigned int)another {
    BOOL result = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *oneDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%u", one]];
    NSDate *anotherDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%u", another]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 2;
    int day1 = (int)[calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:oneDate];
    int day2 = (int)[calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:anotherDate];
    result = [[oneDate addDays:-(day1 - 1)] isEqualToDate:[anotherDate addDays:-(day2 - 1)]];
    return result;
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
//    NSLog(@"KLineViewModel dealloc (%@)", self.code);
}

@end
