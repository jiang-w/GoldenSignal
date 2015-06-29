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

@interface TrendLineChartViewModel()

@property(nonatomic, assign) BOOL initialized;  // 是否加载完历史数据
@property(nonatomic, assign) NSUInteger interval;   // 间隔的分钟数
@property(nonatomic, assign) NSUInteger days;   // 几个交易日

@end

@implementation TrendLineChartViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
}

#pragma mark Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _propertyUpdateQueue = dispatch_queue_create("TrendLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        _lines = [NSMutableArray array];
        self.initialized = NO;
        self.interval = 1;
        self.days = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
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

- (void)setDays:(NSUInteger)days {
    _days = days;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[BDTradingDayService getTradingDaysUntilNowForDays:_days]];
    [arr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    _dates = arr;
}

- (unsigned long)maxVolume {
    NSMutableArray *volumeArr = [NSMutableArray array];
    for (NSString *date in _dates) {
        [volumeArr addObjectsFromArray:[self getVolumeSerialForTradingDay:date]];
    }
    unsigned long max = 0;
    for (NSNumber *val in volumeArr) {
        if ([val unsignedLongValue] > max) {
            max = [val unsignedLongValue];
        }
    }
    return max;
}

#pragma mark Loading date

- (void)loadDataWithSecuCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval {
    if (code) {
        if (_code) {
            [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
        }
        self.initialized = NO;
        self.interval = interval;
        self.days = days;
        _code = [code copy];
        [_lines removeAllObjects];

        _prevClose = [[_service getCurrentIndicateWithCode:_code andName:@"PrevClose"] doubleValue];
        [_service subscribeSerialsWithCode:_code indicateName:@"TrendLine" beginDate:0 beginTime:0 numberType:(int)interval number:(int)days];
        [_service subscribeScalarWithCode:_code indicaters:IndicaterNames];
    }
}


#pragma mark Subscribe

- (void)reconnection {
    if (self.initialized) {
        [self loadDataWithSecuCode:self.code forDays:self.days andInterval:self.interval];
    }
}

- (unsigned int)mergeMinuteWithTime:(unsigned int)time {
    unsigned int mergeMinute = 0;
    unsigned int minute = time / 100000;
    if (minute <= 1130) {
        mergeMinute = floor((time - 930) * 1.0 / self.interval) * self.interval + 930;
    }
    if (minute >= 1300) {
        mergeMinute = floor((time - 1300) * 1.0 / self.interval) * self.interval + 1300;
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
            if ([indicateName isEqualToString:@"TrendLine"] && !self.initialized) {
                @try {
                    NSArray *lineArray = [self paraseTrendLines:[value objectForKey:@"TrendLine"]];
                    [self setValue:lineArray forKey:@"lines"];  // kvo
                    self.initialized = YES;
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineChartViewModel 初始化分时线异常：%@",[exception reason]);
                }
            }
            
            if ([indicateName isEqualToString:@"PrevClose"]) {
                if (value) {
                    [self setValue:value forKey:@"prevClose"];  // kvo
                }
            }
            
            if (self.initialized) {
                @try {
//                    if ([indicateName isEqualToString:@"Date"] || [indicateName isEqualToString:@"Time"]
//                        || [indicateName isEqualToString:@"Now"] || [indicateName isEqualToString:@"Amount"]
//                        || [indicateName isEqualToString:@"Volume"]) {
                    if ([indicateName isEqualToString:@"Time"]) {
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
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineChartViewModel 订阅指标数据异常：%@",[exception reason]);
                }
            }
        });
    }
}

#pragma mark - Chart line

// 获取某交易日（日期格式'yyyy-MM-dd'）的分时线
- (NSArray *)getPricePointInFrame:(CGRect)frame forTradingDay:(NSString *)date {
    NSMutableArray *points = [NSMutableArray array];
    NSArray *priceArr = [self getPriceSerialForTradingDay:date];
    PriceRange priceRange = self.priceRange;
    double scale = (priceRange.high - priceRange.low) / CGRectGetHeight(frame);
    for (int i = 0; i < priceArr.count; i++) {
        double price = [priceArr[i] doubleValue];
        CGPoint point = [self getPointInFrame:frame withScale:scale andValue:price - priceRange.low serialNumber:i];
        [points addObject:NSStringFromCGPoint(point)];
    }
    return points;
}

// 获取某交易日（日期格式'yyyy-MM-dd'）的均线
- (NSArray *)getAvgPricePointInFrame:(CGRect)frame forTradingDay:(NSString *)date {
    NSMutableArray *points = [NSMutableArray array];
    NSArray *priceArr = [self getAvgPriceSerialForTradingDay:date];
    PriceRange priceRange = self.priceRange;
    double scale = (priceRange.high - priceRange.low) / CGRectGetHeight(frame);
    for (int i = 0; i < priceArr.count; i++) {
        double price = [priceArr[i] doubleValue];
        CGPoint point = [self getPointInFrame:frame withScale:scale andValue:price - priceRange.low serialNumber:i];
        [points addObject:NSStringFromCGPoint(point)];
    }
    return points;
}

// 获取某交易日（日期格式'yyyy-MM-dd'）的成交量
- (NSArray *)getVolumePointInFrame:(CGRect)frame forTradingDay:(NSString *)date {
    NSMutableArray *points = [NSMutableArray array];
    NSArray *volumeArr = [self getVolumeSerialForTradingDay:date];
    double scale = self.maxVolume / CGRectGetHeight(frame);
    for (int i = 0; i < volumeArr.count; i++) {
        unsigned long volume = [volumeArr[i] unsignedLongValue];
        CGPoint point = [self getPointInFrame:frame withScale:scale andValue:volume serialNumber:i];
        [points addObject:NSStringFromCGPoint(point)];
    }
    return points;
}

#pragma mark serial

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
                serial[serial.count] = serial[serial.count - 1];
            }
            serial[sn] = [NSNumber numberWithDouble:line.price];
            i++;
        }
    }
    return serial;
}

// 获取某交易日的均价序列（日期格式'yyyy-MM-dd'）
- (NSArray *)getAvgPriceSerialForTradingDay:(NSString *)date {
    NSMutableArray *serial = [NSMutableArray array];
    int dateVal = [[date stringByReplacingOccurrencesOfString:@"-" withString:@""] intValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %d", dateVal];
    NSArray *lines = [_lines filteredArrayUsingPredicate:predicate];
    NSArray *volumes = [self getVolumeSerialForTradingDay:date];
    
    for (int i = 0; i < lines.count; i++) {
        BDTrendLine *line = lines[i];
        double avgPrice = 0;
        if ([volumes[i] unsignedLongValue] > 0) {
            avgPrice = line.amount / [volumes[i] unsignedLongValue];
        }
        [serial addObject:[NSNumber numberWithDouble:avgPrice]];
    }
    return serial;
}

// 获取某交易日的成交量序列（日期格式'yyyy-MM-dd'）
- (NSArray *)getVolumeSerialForTradingDay:(NSString *)date {
    NSMutableArray *serial = [NSMutableArray array];
    int dateVal = [[date stringByReplacingOccurrencesOfString:@"-" withString:@""] intValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %d", dateVal];
    NSArray *lines = [_lines filteredArrayUsingPredicate:predicate];
    int i = 0;
    while (i < lines.count) {
        BDTrendLine *line = lines[i];
        int sn = [self getSerialNumberWithTime:line.time];
        if (i > 0) {
            while (serial.count < sn) {
                [serial addObject:[NSNumber numberWithUnsignedLong:0]];
            }
            BDTrendLine *prevLine = lines[i-1];
            if (sn - [self getSerialNumberWithTime:prevLine.time] == 1) {
                unsigned long volume = line.volume - prevLine.volume;
                [serial addObject:[NSNumber numberWithUnsignedLong:volume]];
            }
            else {
                [serial addObject:[NSNumber numberWithUnsignedLong:0]];
            }
        }
        else {
            if (sn == 0) {
                [serial addObject:[NSNumber numberWithUnsignedLong:line.volume]];
            }
            else {
                [serial addObject:[NSNumber numberWithUnsignedLong:0]];
            }
        }
        i++;
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

- (CGPoint)getPointInFrame:(CGRect)frame withScale:(double)scale andValue:(double)value serialNumber:(int)sn {
    if (sn >= 0) {
        int pointCount = floor(240.0 / _interval) + 2;
        float xOffset = CGRectGetMinX(frame) + sn * CGRectGetWidth(frame) / (pointCount - 1);
        float yOffset = CGRectGetMaxY(frame) - value / scale;
        return CGPointMake(xOffset, yOffset);
    }
    else {
        return CGPointZero;
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [_service unsubscribeScalarWithCode:self.code indicaters:IndicaterNames];
//    NSLog(@"%@ TrendLineChartViewModel dealloc", self.code);
}


@end
