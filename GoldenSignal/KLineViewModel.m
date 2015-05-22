//
//  LiteKLineViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "KLineViewModel.h"
#import "BDQuotationService.h"
#import "BDNetworkService.h"
#import <Foundation/NSCalendar.h>

#define IndicaterNames @[@"Date", @"Now", @"Open", @"High", @"Low", @"Volume"]

@implementation KLineViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
    BDKLine *_todayKLine;
}

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _code = [code copy];
        _initialized = NO;
        _propertyUpdateQueue = dispatch_queue_create("KLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        [_service subscribeScalarWithCode:_code indicaters:IndicaterNames];
        
        // 设置通知
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}

- (void)loadKLineWithType:(KLineType)type andNumber:(int)number {
    _type = type;
    _requestNumber = number;
    _initialized = NO;
    
    //[self httpRequestKLine];
    [self socketRequestKLine];
}

- (void)reconnection {
    if (self.initialized) {
        [self loadKLineWithType:self.type andNumber:_requestNumber];
    }
}

#pragma mark - Property

// 价格区间
- (PriceRange)priceRange {
    float maxPrice = 0;
    float minPrice = 0;
    for (BDKLine *kLine in _lines) {
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
- (unsigned int)maxVolume {
    unsigned int max = 0;
    for (BDKLine *kLine in _lines) {
        if (kLine.volume > max) {
            max = kLine.volume;
        }
    }
    return max;
}

// 设置依赖键(kvo)
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    
    if ([key isEqualToString:@"priceRange"] || [key isEqualToString:@"maxVolume"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"lines", nil];
    }
    
    if (moreKeyPaths) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:moreKeyPaths];
    }
    return keyPaths;
}


#pragma mark - Request KLine

// http request
- (void)httpRequestKLine {
    NSString *url = [NSString stringWithFormat:@"%@/SerialsRequest?code=%@&indicate-name=KLine&number-type=%d&number-from-begin=-%d"
                     , QUOTE_HTTP_URL, self.code, self.type, _requestNumber];
    BDNetworkService *netService = [BDNetworkService sharedInstance];
    [netService asyncGetRequest:url success:^(id responseObject) {
        @try {
            NSMutableArray *lineArray = [NSMutableArray array];
            NSArray *dateArray = [self paraseKLines:responseObject];
            for (id item in dateArray) {
                BDKLine *kLine = [[BDKLine alloc] init];
                kLine.date = [[item objectForKey:@"date"] intValue];
                kLine.high = [[item objectForKey:@"high"] floatValue];
                kLine.low = [[item objectForKey:@"low"] floatValue];
                kLine.open = [[item objectForKey:@"open"] floatValue];
                kLine.close = [[item objectForKey:@"now"] floatValue];
                kLine.volume = [[item objectForKey:@"Volume"] unsignedIntValue];
                [lineArray addObject:kLine];
            }
            [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
            [self setValue:lineArray forKey:@"lines"];
            
            _initialized = YES;
            [self observerTodayKLine];
        }
        @catch (NSException *exception) {
            NSLog(@"KLineViewModel 初始化K线异常：%@",[exception reason]);
        }
    } failure:nil];
}

// 解析K线数据
- (NSArray *)paraseKLines:(NSData *)data {
    if (data) {
        NSError *error;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *kLineArray = jsonDic[@"serials"][@"data"];
        return kLineArray;
    }
    else {
        return nil;
    }
}

// socket request
- (void)socketRequestKLine {
    [_service subscribeSerialsWithCode:_code indicateName:@"KLine" beginDate:0 beginTime:0 numberType:self.type number:_requestNumber];
}


#pragma mark Subscribe

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if (self.code && [self.code isEqualToString:code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            if ([indicateName isEqualToString:@"KLine"] && !self.initialized) {
                @try {
                    NSMutableArray *lineArray = [NSMutableArray array];
                    for (id item in [value objectForKey:@"KLine"]) {
                        BDKLine *kLine = [[BDKLine alloc] init];
                        kLine.date = [[item objectForKey:@"Date"] intValue];
                        kLine.high = [[item objectForKey:@"High"] floatValue];
                        kLine.low = [[item objectForKey:@"Low"] floatValue];
                        kLine.open = [[item objectForKey:@"Open"] floatValue];
                        kLine.close = [[item objectForKey:@"Now"] floatValue];
                        kLine.volume = [[item objectForKey:@"Volume"] unsignedIntValue];
                        [lineArray addObject:kLine];
                    }
                    [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
                    [self setValue:lineArray forKey:@"lines"];
                    
                    _initialized = YES;
                    [self observerTodayKLine];
                }
                @catch (NSException *exception) {
                    NSLog(@"KLineViewModel 初始化K线异常：%@",[exception reason]);
                }
            }
            
            if (self.initialized) {
                @try {
                    if ([indicateName isEqualToString:@"Date"]) {
                        int date = [value intValue];
                        if (_todayKLine.date != 0 && date > _todayKLine.date) {
                            [self observerTodayKLine];
                        }
                        else {
                            _todayKLine.date = date;
                        }
                    }
                    if ([indicateName isEqualToString:@"High"]) {
                        _todayKLine.high = [value floatValue];
                    }
                    if ([indicateName isEqualToString:@"Low"]) {
                        _todayKLine.low = [value floatValue];
                    }
                    if ([indicateName isEqualToString:@"Open"]) {
                        _todayKLine.open = [value floatValue];
                    }
                    if ([indicateName isEqualToString:@"Now"]) {
                        _todayKLine.close = [value floatValue];
                    }
                    if ([indicateName isEqualToString:@"Volume"]) {
                        _todayKLine.volume = [value intValue];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"KLineViewModel 订阅指标数据异常：%@",[exception reason]);
                }
            }
        });
    }
}

#pragma mark KVO

- (void)observerTodayKLine {
    if (_todayKLine) {
        [self removeObserverForTodayKLine];
    }
    else {
        _todayKLine = [[BDKLine alloc] init];
        [self AddObserverForTodayKLine];
        _todayKLine.date = [[_service getCurrentIndicateWithCode:_code andName:@"Date"] intValue];
        _todayKLine.close = [[_service getCurrentIndicateWithCode:_code andName:@"Now"] floatValue];
        _todayKLine.open = [[_service getCurrentIndicateWithCode:_code andName:@"Open"] floatValue];
        _todayKLine.high = [[_service getCurrentIndicateWithCode:_code andName:@"High"] floatValue];
        _todayKLine.low = [[_service getCurrentIndicateWithCode:_code andName:@"Low"] floatValue];
        _todayKLine.volume = [[_service getCurrentIndicateWithCode:_code andName:@"Volume"] unsignedIntValue];
    }
}

- (void)AddObserverForTodayKLine {
    [_todayKLine addObserver:self forKeyPath:@"date" options:NSKeyValueObservingOptionNew context:NULL];
    [_todayKLine addObserver:self forKeyPath:@"high" options:NSKeyValueObservingOptionNew context:NULL];
    [_todayKLine addObserver:self forKeyPath:@"open" options:NSKeyValueObservingOptionNew context:NULL];
    [_todayKLine addObserver:self forKeyPath:@"low" options:NSKeyValueObservingOptionNew context:NULL];
    [_todayKLine addObserver:self forKeyPath:@"close" options:NSKeyValueObservingOptionNew context:NULL];
    [_todayKLine addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserverForTodayKLine {
    [_todayKLine removeObserver:self forKeyPath:@"date"];
    [_todayKLine removeObserver:self forKeyPath:@"high"];
    [_todayKLine removeObserver:self forKeyPath:@"open"];
    [_todayKLine removeObserver:self forKeyPath:@"low"];
    [_todayKLine removeObserver:self forKeyPath:@"close"];
    [_todayKLine removeObserver:self forKeyPath:@"volume"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    @try {
        BDKLine *latestLine = [_lines lastObject];
        switch (self.type) {
            case KLINE_DAY:
                if (_todayKLine.date > latestLine.date) {
                    [_lines addObject:_todayKLine];
                    [_lines removeObjectAtIndex:0];
                }
                break;
            case KLINE_WEEK:
            {
                int currentWeek = [self weekOfYearWithDate:_todayKLine.date];
                int latestWeek = [self weekOfYearWithDate:latestLine.date];
                if (currentWeek == latestWeek && latestLine != _todayKLine) {
                    if (_todayKLine.high > latestLine.high) {
                        latestLine.high = _todayKLine.high;
                    }
                    if (_todayKLine.low > 0 && _todayKLine.low < latestLine.low) {
                        latestLine.low = _todayKLine.low;
                    }
                    if (_todayKLine.close > 0) {
                        latestLine.close = _todayKLine.close;
                    }
                }
                else if (_todayKLine.date > latestLine.date) {
                    [_lines addObject:_todayKLine];
                    [_lines removeObjectAtIndex:0];
                }
            }
                break;
            case KLINE_MONTH:
            {
                int currentMonth = _todayKLine.date % 10000 / 100;
                int latestMonth = latestLine.date % 10000 / 100;
                if (currentMonth == latestMonth) {
                    if (_todayKLine.high > latestLine.high) {
                        latestLine.high = _todayKLine.high;
                    }
                    if (_todayKLine.low > 0 && _todayKLine.low < latestLine.low) {
                        latestLine.low = _todayKLine.low;
                    }
                    if (_todayKLine.close > 0) {
                        latestLine.close = _todayKLine.close;
                    }
                }
                else if (_todayKLine.date > latestLine.date) {
                    [_lines addObject:_todayKLine];
                    [_lines removeObjectAtIndex:0];
                }
            }
                break;
            default:
                break;
        }
        
        if (_todayKLine.high != 0 && _todayKLine.open != 0 && _todayKLine.low != 0 && _todayKLine.close != 0) {
            [self setValue:self.lines forKey:@"lines"];
        }
        
    }
    @catch (NSException *exception) {
        
    }
}

// 获取日期为该年的第几周
- (int)weekOfYearWithDate:(int)value {
    int week = 0;
    int year = value / 10000;
    int month = (value % 10000) / 100;
    int day = value % 100;
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:year];
    [comp setMonth:month];
    [comp setDay:day];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:comp];
    comp = [calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    week = (int)comp.weekOfYear;
    return week;
}

// 计算均价
- (float)calcAvgPriceForDate:(int)date andMA:(int)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"date <= %d", date]];
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[self.lines filteredArrayUsingPredicate:predicate]];
    [lines sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    if (lines.count >= value) {
        NSRange range = NSMakeRange(0, value);
        NSArray *subArray = [lines subarrayWithRange:range];
        float totalPrice = 0;
        for (BDKLine *line in subArray) {
            totalPrice += line.close;
        }
        return totalPrice / subArray.count;
    }
    else {
        return 0;
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [self removeObserverForTodayKLine];
    [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
    //NSLog(@"%@ KLineViewModel dealloc", self.code);
}

@end
