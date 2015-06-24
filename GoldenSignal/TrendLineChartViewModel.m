//
//  TrendLineChartViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TrendLineChartViewModel.h"
#import "BDQuotationService.h"

#define IndicaterNames @[@"Date", @"Time", @"Now", @"Amount", @"Volume", @"PrevClose"]

@implementation TrendLineChartViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
    BDTrendLine *_latestLine;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaultParameters];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
//        [[NSNotificationCenter defaultCenter]
//         addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}

- (void)setDefaultParameters {
    _propertyUpdateQueue = dispatch_queue_create("TrendLineUpdate", nil);
    _service = [BDQuotationService sharedInstance];
    _latestLine = nil;
    _initialized = NO;
}

- (void)loadTrendLineWithSecuCode:(NSString *)code ForDays:(int)days andInterval:(int)interval {
    if (code != nil && ![code isEqualToString:_code]) {
        if (_code) {
            [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
        }
        _code = [code copy];
        [_service subscribeSerialsWithCode:_code indicateName:@"TrendLine" beginDate:0 beginTime:0 numberType:interval number:days];
        [_service subscribeScalarWithCode:_code indicaters:IndicaterNames];
    }
}

#pragma mark Subscribe

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

//                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                    NSMutableArray *dateArray = [NSMutableArray array];
//                    for (id item in [value objectForKey:@"TrendLine"]) {
//                        BDTrendLine *line = [[BDTrendLine alloc] init];
//                        line.date = [[item objectForKey:@"Date"] unsignedIntValue];
//                        line.time = [[item objectForKey:@"Time"] unsignedIntValue] / 100000;
//                        line.price = [[item objectForKey:@"Now"] doubleValue];
//                        line.amount = [[item objectForKey:@"Amount"] doubleValue];
//                        line.volume = [[item objectForKey:@"Volume"] unsignedLongValue];
//                        // 添加走势线
//                        NSString *key = [NSString stringWithFormat:@"%d%d", line.date, line.time];
//                        if ([dic.allKeys containsObject:key]) {
//                            if (line.volume > ((BDTrendLine *)dic[key]).volume) {
//                                [dic setObject:line forKey:key];
//                            }
//                        }
//                        else {
//                            [dic setObject:line forKey:key];
//                        }
//                        // 添加日期
//                        if (![dateArray containsObject:[NSNumber numberWithInt:line.date]]) {
//                            [dateArray addObject:[NSNumber numberWithInt:line.date]];
//                        }
//                    }
//                    // 对走势线进行过滤和排序
//                    NSMutableArray *lineArray = [NSMutableArray arrayWithArray:dic.allValues];
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= 930 and time <= 1500"];
//                    lineArray = [NSMutableArray arrayWithArray:[lineArray filteredArrayUsingPredicate:predicate]];
//                    [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
//                                                      [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]]];
//                    [self setValue:lineArray forKey:@"lines"];  // kvo
//                    // 对日期进行排序
//                    [dateArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
//                    [self setValue:dateArray forKey:@"dates"];
//                    
//                    _initialized = YES;
//                    id prevCloseValue = [_service getCurrentIndicateWithCode:self.code andName:@"PrevClose"];
//                    if (prevCloseValue) {
//                        [self setValue:prevCloseValue forKey:@"prevClose"];
//                    }
//                    _latestLine = [[BDTrendLine alloc] init];
//                    _latestLine.date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] intValue];
//                    _latestLine.time = [[_service getCurrentIndicateWithCode:self.code andName:@"Time"] intValue] / 100000;
//                    _latestLine.price = [[_service getCurrentIndicateWithCode:self.code andName:@"Now"] floatValue];
//                    _latestLine.amount = [[_service getCurrentIndicateWithCode:self.code andName:@"Amount"] floatValue];
//                    _latestLine.volume = [[_service getCurrentIndicateWithCode:self.code andName:@"Volume"] intValue];
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineViewModel 初始化分时线异常：%@",[exception reason]);
                }
            }
//
//            if (self.initialized) {
//                @try {
//                    if ([indicateName isEqualToString:@"Date"]) {
//                        _latestLine.date = [value intValue];
//                    }
//                    else if ([indicateName isEqualToString:@"Time"]) {
//                        _latestLine.time = [value intValue] / 100000;
//                    }
//                    else if ([indicateName isEqualToString:@"Now"]) {
//                        _latestLine.price = [value floatValue];
//                    }
//                    else if ([indicateName isEqualToString:@"Amount"]) {
//                        _latestLine.amount = [value doubleValue];
//                    }
//                    else if ([indicateName isEqualToString:@"Volume"]) {
//                        _latestLine.volume = [value unsignedIntValue];
//                        
//                        BDTrendLine *lastLine = [self.lines lastObject];
//                        int mergeMinute = floor((_latestLine.time - lastLine.time) * 1.0 / self.interval) * self.interval + lastLine.time;
//                        if (mergeMinute == lastLine.time) {
//                            lastLine.price = _latestLine.price;
//                            lastLine.amount = _latestLine.amount;
//                            lastLine.volume = _latestLine.volume;
//                        }
//                        else {
//                            BDTrendLine *newLine = [[BDTrendLine alloc] init];
//                            newLine.date = _latestLine.date;
//                            newLine.time = mergeMinute;
//                            newLine.price = _latestLine.price;
//                            newLine.amount = _latestLine.amount;
//                            newLine.volume = _latestLine.volume;
//                            [self.lines addObject:newLine];
//                        }
//                        [self setValue:self.lines forKey:@"lines"];  // kvo
//                    }
//                    else if ([indicateName isEqualToString:@"PrevClose"]) {
//                        if (value) {
//                            [self setValue:value forKey:@"prevClose"];  // kvo
//                        }
//                    }
//                }
//                @catch (NSException *exception) {
//                    NSLog(@"TrendLineViewModel 订阅指标数据异常：%@",[exception reason]);
//                }
//            }
        });
    }
}

@end
