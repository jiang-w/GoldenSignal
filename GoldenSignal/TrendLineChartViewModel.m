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
}

#pragma mark Init

- (instancetype)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _propertyUpdateQueue = dispatch_queue_create("TrendLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        _code = [code copy];
        
        [self setDefaultParameters];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}

- (void)setDefaultParameters {
    _initialized = NO;
    _lines = [NSMutableArray array];
    _interval = 1;
    _dates = [BDTradingDayService getTradingDaysUntilNowForDays:1];
}

#pragma mark Property

// 价格区间
- (PriceRange)priceRange {
    float max = 0;
    for (BDTrendLine *line in _lines) {
        float dif = fabs(line.price - _prevClose);
        if (dif > max) {
            max = dif;
        }
    }
    return (PriceRange){_prevClose - max, _prevClose + max};
}

#pragma mark Loading date

- (void)loadTrendLineForDays:(NSUInteger)days andInterval:(NSUInteger)interval {
    _interval = interval;
    _initialized = NO;
    _dates = [BDTradingDayService getTradingDaysUntilNowForDays:days];
    [_service subscribeSerialsWithCode:_code indicateName:@"TrendLine" beginDate:0 beginTime:0 numberType:(int)interval number:(int)days];
    [_service subscribeScalarWithCode:_code indicaters:IndicaterNames];
}


#pragma mark Subscribe

- (void)reconnection {
    if (_initialized) {
        [self loadTrendLineForDays:_dates.count andInterval:_interval];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= 930 and time <= 1500"];
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
            
            if (self.initialized) {
                @try {
                    if ([indicateName isEqualToString:@"Date"] || [indicateName isEqualToString:@"Time"]
                        || [indicateName isEqualToString:@"Now"] || [indicateName isEqualToString:@"Amount"]
                        || [indicateName isEqualToString:@"Volume"]) {
                        unsigned int date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] unsignedIntValue];
                        unsigned int time = [[_service getCurrentIndicateWithCode:self.code andName:@"Time"] unsignedIntValue];
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

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [_service unsubscribeScalarWithCode:self.code indicaters:IndicaterNames];
    NSLog(@"%@ TrendLineChartViewModel dealloc", self.code);
}


@end
