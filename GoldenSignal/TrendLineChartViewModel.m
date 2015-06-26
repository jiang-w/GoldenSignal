//
//  TrendLineChartViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TrendLineChartViewModel.h"
#import "BDQuotationService.h"
#import "BDTradingDayService.h"

#define IndicaterNames @[@"Date", @"Time", @"Now", @"Amount", @"Volume", @"PrevClose"]

@implementation TrendLineChartViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
    BOOL _initialized;  // 是否加载完历史数据
    NSUInteger _interval;   // 间隔的分钟数
    NSUInteger _days;   // 几个交易日
}

#pragma mark Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _propertyUpdateQueue = dispatch_queue_create("TrendLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        [self initProperties];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}

- (void)initProperties {
    _initialized = NO;
    _interval = 1;
    _days = 1;
    _lines = [NSMutableArray array];
}

#pragma mark Property

// 价格区间
- (PriceRange)priceRange {
    double max = 0;
    for (BDTrendLine *line in _lines) {
        double dif = fabs(line.price - _prevClose);
        if (dif > max) {
            max = dif;
        }
    }
    return (PriceRange){_prevClose - max, _prevClose + max};
}

- (NSArray *)dates {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[BDTradingDayService getTradingDaysUntilNowForDays:_days]];
    [arr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    return arr;
}

#pragma mark Loading date

- (void)loadDataWithSecuCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval {
    if (code) {
        if (_code) {
            [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
        }
        [self setValue:[code copy] forKey:@"code"];
        _initialized = NO;
        _interval = interval;
        _days = days;
        [_lines removeAllObjects];
        [_service subscribeSerialsWithCode:_code indicateName:@"TrendLine" beginDate:0 beginTime:0 numberType:(int)interval number:(int)days];
        [_service subscribeScalarWithCode:_code indicaters:IndicaterNames];
    }
}


#pragma mark Subscribe

- (void)reconnection {
    if (_initialized) {
        [self loadDataWithSecuCode:_code forDays:_days andInterval:_interval];
    }
}

- (unsigned int)mergeMinuteWithTime:(unsigned int)time {
    unsigned int mergeMinute = 0;
    unsigned int minute = time / 100000;
    if (minute <= 1130) {
        mergeMinute = floor((time - 930) * 1.0 / _interval) * _interval + 930;
    }
    if (minute >= 1300) {
        mergeMinute = floor((time - 1300) * 1.0 / _interval) * _interval + 1300;
    }
    return mergeMinute;
}

- (NSArray *)paraseTrendLines:(NSArray *)data {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *item in data) {
        BDTrendLine *line = [[BDTrendLine alloc] init];
        line.date = [[item objectForKey:@"Date"] unsignedIntValue];
        line.time = [[item objectForKey:@"Time"] unsignedIntValue] / 100000;
        line.price = [[item objectForKey:@"Now"] doubleValue];
        line.amount = [[item objectForKey:@"Amount"] doubleValue];
        line.volume = [[item objectForKey:@"Volume"] unsignedLongValue];
        [arr addObject:line];
    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= 930 and time <= 1500"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time BETWEEN {930, 1130} or time BETWEEN {1300, 1500}"];
    arr = [NSMutableArray arrayWithArray:[arr filteredArrayUsingPredicate:predicate]];
    [arr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                                     [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]]];
    return arr;
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if (self.code && [self.code isEqualToString:code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            if ([indicateName isEqualToString:@"TrendLine"] && !_initialized) {
                @try {
                    NSArray *lineArray = [self paraseTrendLines:[value objectForKey:@"TrendLine"]];
                    [self setValue:lineArray forKey:@"lines"];  // kvo
                    _initialized = YES;
                    id prevCloseValue = [_service getCurrentIndicateWithCode:self.code andName:@"PrevClose"];
                    if (prevCloseValue) {
                        [self setValue:prevCloseValue forKey:@"prevClose"];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineChartViewModel 初始化分时线异常：%@",[exception reason]);
                }
            }
            
            if (_initialized) {
                @try {
                    if ([indicateName isEqualToString:@"Date"] || [indicateName isEqualToString:@"Time"]
                        || [indicateName isEqualToString:@"Now"] || [indicateName isEqualToString:@"Amount"]
                        || [indicateName isEqualToString:@"Volume"]) {
                        unsigned int date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] unsignedIntValue];
                        unsigned int time = [[_service getCurrentIndicateWithCode:self.code andName:@"Time"] unsignedIntValue] / 100000;
                        double price = [[_service getCurrentIndicateWithCode:self.code andName:@"Now"] doubleValue];
                        double amount = [[_service getCurrentIndicateWithCode:self.code andName:@"Amount"] doubleValue];
                        unsigned long volume = [[_service getCurrentIndicateWithCode:self.code andName:@"Volume"] unsignedLongValue];
                        
                        unsigned int mergeMinute = [self mergeMinuteWithTime:time];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %lu", date];
                        NSMutableArray *lineArray = [NSMutableArray arrayWithArray:[self.lines filteredArrayUsingPredicate:predicate]];
                        [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
                        BDTrendLine *line = [lineArray firstObject];
                        if (line == nil || mergeMinute > line.time) {
                            line = [[BDTrendLine alloc] init];
                            line.date = date;
                            line.time = mergeMinute;
                            [self.lines addObject:line];
                        }
                        line.price = price;
                        line.amount = amount;
                        line.volume = volume;
                        
                        [self setValue:self.lines forKey:@"lines"];  // kvo
                    }
                    else if ([indicateName isEqualToString:@"PrevClose"]) {
                        if (value) {
                            [self setValue:value forKey:@"prevClose"];  // kvo
                        }
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineChartViewModel 订阅指标数据异常：%@",[exception reason]);
                }
            }
        });
    }
}

#pragma mark - View

// 获取某交易日（日期格式'yyyy-MM-dd'）的分时点
- (NSArray *)getPricePointInFrame:(CGRect)frame forTradingDay:(NSString *)date {
    NSMutableArray *points = [NSMutableArray array];
    NSArray *priceArr = [self getPriceSerialForTradingDay:date];
    PriceRange priceRange = self.priceRange;
    
    for (int i = 0; i < priceArr.count; i++) {
        double price = [priceArr[i] doubleValue];
        CGFloat xOffset = CGRectGetMinX(frame) + i * CGRectGetWidth(frame) / (priceArr.count - 1);
        CGFloat yOffset = CGRectGetMinY(frame) + (priceRange.high - price) / (priceRange.high - priceRange.low) * CGRectGetHeight(frame);
        CGPoint point = CGPointMake(xOffset, yOffset);
        [points addObject:NSStringFromCGPoint(point)];
    }
    return points;
}

// 获取某交易日的价格序列（日期格式'yyyy-MM-dd'）
- (NSArray *)getPriceSerialForTradingDay:(NSString *)date {
    NSMutableArray *serial = [NSMutableArray array];
    int dateVal = [[date stringByReplacingOccurrencesOfString:@"-" withString:@""] intValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %d", dateVal];
    NSArray *lines = [_lines filteredArrayUsingPredicate:predicate];

    int i = 0;
    while (i < lines.count) {
        BDTrendLine *line = lines[i];
        int sn = [self getSerialNumberWithTime:line.time];
        if (serial.count == 0) {
            serial[0] = [NSNumber numberWithDouble:line.price];
        }
        else {
            while (serial.count < sn) {
                serial[serial.count - 1] = serial[serial.count - 2];
            }
            serial[sn] = [NSNumber numberWithDouble:line.price];
            i++;
        }
    }
    return serial;
}

- (int)getSerialNumberWithTime:(int)time {
    int sn = -1;
    if (time >= 930 && time <= 1130) {
        int escapeMintue = (time / 100 * 60 + time % 100) - (9 * 60 + 30);
        sn = floor(escapeMintue * 1.0 / _interval);
    }
    if (time >= 1300 && time <= 1500) {
        int escapeMintue = (time / 100 * 60 + time % 100) - 13 * 60;
        sn = floor(120.0 / _interval) + 1 + floor(escapeMintue * 1.0 / _interval);
    }
    return sn;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [_service unsubscribeScalarWithCode:self.code indicaters:IndicaterNames];
    NSLog(@"%@ TrendLineChartViewModel dealloc", self.code);
}


@end
