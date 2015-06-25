//
//  BDTrendViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/2/5.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TrendLineViewModel.h"
#import "BDQuotationService.h"
#import "BDNetworkService.h"

#define IndicaterNames @[@"Date", @"Time", @"Now", @"Amount", @"Volume", @"PrevClose"]

@implementation TrendLineViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
    BDTrendLine *_latestLine;
}

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _code = code;
        _initialized = NO;
        _requestDays = 1;
        _interval = 1;
        _propertyUpdateQueue = dispatch_queue_create("TrendLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        [_service subscribeScalarWithCode:self.code indicaters:IndicaterNames];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(reconnection) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}

- (void)loadTrendLineForDays:(int)days andInterval:(int)interval {
    _requestDays = days;
    _interval = interval;
    _initialized = NO;
    
    //[self httpRequestTrendLine];
    [self socketRequestTrendLine];
}

- (void)reconnection {
    if (self.initialized) {
        [self loadTrendLineForDays:_requestDays andInterval:self.interval];
    }
}

#pragma mark - Property

// 价格区间
- (PriceRange)priceRange {
    float max = 0;
    for (BDTrendLine *line in self.lines) {
        float dif = fabs(line.price - _prevClose);
        if (dif > max) {
            max = dif;
        }
    }
    return (PriceRange){_prevClose - max, _prevClose + max};
}

// 最大交易量
- (unsigned int)maxVolume {
    unsigned int max = 0;
    for (int i = 1; i < self.lines.count; i++) {
        BDTrendLine *prevLine = self.lines[i - 1];
        BDTrendLine *currentLine = self.lines[i];
        unsigned int volumeChange = currentLine.volume - prevLine.volume;
        if (prevLine.date == currentLine.date && volumeChange > max) {
            max = volumeChange;
        }
    }
    return max;
}

// 设置依赖键(kvo)
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    
    if ([key isEqualToString:@"priceRange"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"lines", @"prevClose", nil];
    }
    if ([key isEqualToString:@"maxVolume"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"lines", nil];
    }
    
    if (moreKeyPaths) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:moreKeyPaths];
    }
    return keyPaths;
}


#pragma mark - Request TrendLine

// http request
- (void)httpRequestTrendLine {
    NSString *url = [NSString stringWithFormat:@"%@/SerialsRequest?code=%@&indicate-name=TrendLine&number-type=%d&number-from-begin=-%d"
                     , QUOTE_HTTP_URL, self.code, self.interval, _requestDays];
    BDNetworkService *netService = [BDNetworkService sharedInstance];
    [netService asyncGetRequest:url success:^(id responseObject) {
        @try {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSMutableArray *dateArray = [NSMutableArray array];
            NSArray *response = [self paraseTrendLines:responseObject];
            for (id item in response) {
                BDTrendLine *line = [[BDTrendLine alloc] init];
                line.date = [[item objectForKey:@"date"] unsignedIntValue];
                line.time = [[item objectForKey:@"time"] unsignedIntValue] / 100000;
                line.price = [[item objectForKey:@"now"] doubleValue];
                line.amount = [[item objectForKey:@"amount"] doubleValue];
                line.volume = [[item objectForKey:@"volume"] unsignedLongValue];
                // 添加走势线
                NSString *key = [NSString stringWithFormat:@"%d%d", line.date, line.time];
                if ([dic.allKeys containsObject:key]) {
                    if (line.volume > ((BDTrendLine *)dic[key]).volume) {
                        [dic setObject:line forKey:key];
                    }
                }
                else {
                    [dic setObject:line forKey:key];
                }
                // 添加日期
                if (![dateArray containsObject:[NSNumber numberWithInt:line.date]]) {
                    [dateArray addObject:[NSNumber numberWithInt:line.date]];
                }
            }
            // 对走势线进行过滤和排序
            NSMutableArray *lineArray = [NSMutableArray arrayWithArray:dic.allValues];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= 930 and time <= 1500"];
            lineArray = [NSMutableArray arrayWithArray:[lineArray filteredArrayUsingPredicate:predicate]];
            [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                                              [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]]];
            [self setValue:lineArray forKey:@"lines"];  // kvo
            // 对日期进行排序
            [dateArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
            [self setValue:dateArray forKey:@"dates"];
            
            _initialized = YES;
            [self setValue:[_service getCurrentIndicateWithCode:self.code andName:@"PrevClose"] forKey:@"prevClose"];
            _latestLine = [[BDTrendLine alloc] init];
            _latestLine.date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] intValue];
            _latestLine.time = [[_service getCurrentIndicateWithCode:self.code andName:@"Time"] intValue];
            _latestLine.price = [[_service getCurrentIndicateWithCode:self.code andName:@"Now"] floatValue];
            _latestLine.amount = [[_service getCurrentIndicateWithCode:self.code andName:@"Amount"] floatValue];
            _latestLine.volume = [[_service getCurrentIndicateWithCode:self.code andName:@"Volume"] intValue];
        }
        @catch (NSException *exception) {
            NSLog(@"TrendLineViewModel 初始化分时线异常：%@",[exception reason]);
        }
        
    } failure:nil];
}

// 解析分时线数据
- (NSArray *)paraseTrendLines:(NSData *)data {
    if (data) {
        NSError *error;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *trendLineArray = jsonDic[@"serials"][@"data"];
        return trendLineArray;
    }
    else {
        return nil;
    }
}

// socket request
- (void)socketRequestTrendLine {
    [_service subscribeSerialsWithCode:self.code indicateName:@"TrendLine" beginDate:0 beginTime:0 numberType:self.interval number:_requestDays];
}


#pragma mark Subscribe

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if (self.code && [self.code isEqualToString:code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            if ([indicateName isEqualToString:@"TrendLine"] && !self.initialized) {
                @try {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    NSMutableArray *dateArray = [NSMutableArray array];
                    for (id item in [value objectForKey:@"TrendLine"]) {
                        BDTrendLine *line = [[BDTrendLine alloc] init];
                        line.date = [[item objectForKey:@"Date"] unsignedIntValue];
                        line.time = [[item objectForKey:@"Time"] unsignedIntValue] / 100000;
                        line.price = [[item objectForKey:@"Now"] doubleValue];
                        line.amount = [[item objectForKey:@"Amount"] doubleValue];
                        line.volume = [[item objectForKey:@"Volume"] unsignedLongValue];
                        // 添加走势线
                        NSString *key = [NSString stringWithFormat:@"%d%d", line.date, line.time];
                        if ([dic.allKeys containsObject:key]) {
                            if (line.volume > ((BDTrendLine *)dic[key]).volume) {
                                [dic setObject:line forKey:key];
                            }
                        }
                        else {
                            [dic setObject:line forKey:key];
                        }
                        // 添加日期
                        if (![dateArray containsObject:[NSNumber numberWithInt:line.date]]) {
                            [dateArray addObject:[NSNumber numberWithInt:line.date]];
                        }
                    }
                    // 对走势线进行过滤和排序
                    NSMutableArray *lineArray = [NSMutableArray arrayWithArray:dic.allValues];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= 930 and time <= 1500"];
                    lineArray = [NSMutableArray arrayWithArray:[lineArray filteredArrayUsingPredicate:predicate]];
                    [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                                                      [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]]];
                    [self setValue:lineArray forKey:@"lines"];  // kvo
                    // 对日期进行排序
                    [dateArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
                    [self setValue:dateArray forKey:@"dates"];
                    
                    _initialized = YES;
                    id prevCloseValue = [_service getCurrentIndicateWithCode:self.code andName:@"PrevClose"];
                    if (prevCloseValue) {
                        [self setValue:prevCloseValue forKey:@"prevClose"];
                    }
                    _latestLine = [[BDTrendLine alloc] init];
                    _latestLine.date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] intValue];
                    _latestLine.time = [[_service getCurrentIndicateWithCode:self.code andName:@"Time"] intValue] / 100000;
                    _latestLine.price = [[_service getCurrentIndicateWithCode:self.code andName:@"Now"] floatValue];
                    _latestLine.amount = [[_service getCurrentIndicateWithCode:self.code andName:@"Amount"] floatValue];
                    _latestLine.volume = [[_service getCurrentIndicateWithCode:self.code andName:@"Volume"] intValue];
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineViewModel 初始化分时线异常：%@",[exception reason]);
                }
            }
            
            if (self.initialized) {
                @try {
                    if ([indicateName isEqualToString:@"Date"]) {
                        _latestLine.date = [value unsignedIntValue];
                    }
                    else if ([indicateName isEqualToString:@"Time"]) {
                        _latestLine.time = [value unsignedIntValue] / 100000;
                    }
                    else if ([indicateName isEqualToString:@"Now"]) {
                        _latestLine.price = [value doubleValue];
                    }
                    else if ([indicateName isEqualToString:@"Amount"]) {
                        _latestLine.amount = [value doubleValue];
                    }
                    else if ([indicateName isEqualToString:@"Volume"]) {
                        _latestLine.volume = [value unsignedLongValue];
                        
                        BDTrendLine *lastLine = [self.lines lastObject];
                        int mergeMinute = floor((_latestLine.time - lastLine.time) * 1.0 / self.interval) * self.interval + lastLine.time;
                        if (mergeMinute == lastLine.time) {
                            lastLine.price = _latestLine.price;
                            lastLine.amount = _latestLine.amount;
                            lastLine.volume = _latestLine.volume;
                        }
                        else {
                            BDTrendLine *newLine = [[BDTrendLine alloc] init];
                            newLine.date = _latestLine.date;
                            newLine.time = mergeMinute;
                            newLine.price = _latestLine.price;
                            newLine.amount = _latestLine.amount;
                            newLine.volume = _latestLine.volume;
                            [self.lines addObject:newLine];
                        }
                        [self setValue:self.lines forKey:@"lines"];  // kvo
                    }
                    else if ([indicateName isEqualToString:@"PrevClose"]) {
                        if (value) {
                            [self setValue:value forKey:@"prevClose"];  // kvo
                        }
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"TrendLineViewModel 订阅指标数据异常：%@",[exception reason]);
                }
            }
        });
    }
}


#pragma mark - View

- (CGPoint)getPointInFrame:(CGRect)frame WithSerialNumber:(int)number andPrice:(float)price {
    PriceRange priceRange = self.priceRange;
    if (number >= 0) {
        int pointCount = floor(240.0 / self.interval) + 2;
        float xOffset = CGRectGetMinX(frame) + number * CGRectGetWidth(frame) / (pointCount - 1);
        float yOffset = CGRectGetMinY(frame) + (priceRange.high - price) / (priceRange.high - priceRange.low) * CGRectGetHeight(frame);
        return CGPointMake(xOffset, yOffset);
    }
    else {
        return CGPointZero;
    }
}

- (int)getSerialNumberWithTime:(int)time {
    int sn = -1;
    if (time >= 930 && time <= 1130) {
        int escapeMintue = (time / 100 * 60 + time % 100) - (9 * 60 + 30);
        sn = floor(escapeMintue * 1.0 / self.interval);
    }
    if (time >= 1300 && time <= 1500) {
        int escapeMintue = (time / 100 * 60 + time % 100) - 13 * 60;
        sn = floor(120.0 / self.interval) + 1 + floor(escapeMintue * 1.0 / self.interval);
    }
    return sn;
}

- (int)getTimeWithSerialNumber:(int)number {
    int time = 0;
    int threshold = [self getSerialNumberWithTime:1300];
    if (number < threshold) {
        int mintue = 9 * 60 + 30 + number * self.interval;
        time = mintue / 60 * 100 + mintue % 60;
    }
    else {
        int mintue = 13 * 60 + (number - threshold) * self.interval;
        time = mintue / 60 * 100 + mintue % 60;
    }
    return time;
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [_service unsubscribeScalarWithCode:self.code indicaters:IndicaterNames];
    //NSLog(@"%@ TrendLineViewModel dealloc", self.code);
}

@end
