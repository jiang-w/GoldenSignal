//
//  KLineChartViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "KLineChartViewModel.h"
#import "BDQuotationService.h"

#define IndicaterNames @[@"Date", @"Time", @"Now", @"Open", @"High", @"Low", @"Volume"]

@interface KLineChartViewModel()

@property(nonatomic, assign) BOOL initialized;  // 是否加载完历史数据
@property(nonatomic, assign) KLineType type;    // K线的类型（日K、周K、月K）
@property(nonatomic, assign) NSUInteger number; // K线数量

@end

@implementation KLineChartViewModel
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


#pragma mark Loading date

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
            [_service subscribeSerialsWithCode:_code indicateName:@"KLine" beginDate:0 beginTime:0 numberType:(int)_type number:(int)_number];
        }
    }
}


#pragma mark Subscribe

- (void)reconnection {
    self.initialized = NO;
    [self loadDataWithSecuCode:self.code forType:self.type andNumber:self.number];
}

- (NSArray *)paraseTrendLines:(NSArray *)data {
    NSMutableArray *arr = [NSMutableArray array];
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
                @try {
                    NSUInteger number = [dic[@"numberFromBegin"] intValue];
                    KLineType type = (KLineType)[dic[@"numberType"] intValue];
                    if (self.type == type && self.number == number) {
                        NSArray *lineArray = [self paraseTrendLines:[value objectForKey:@"KLine"]];
                        [self setValue:lineArray forKey:@"lines"];  // kvo
                        self.initialized = YES;
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"KLineChartViewModel 初始化K线异常：%@", [exception reason]);
                }
            }
            
            if (self.initialized) {
                @try {
                    if ([indicateName isEqualToString:@"Time"]) {
                        unsigned int date = [[_service getCurrentIndicateWithCode:self.code andName:@"Date"] unsignedIntValue];
                        double price = [[_service getCurrentIndicateWithCode:self.code andName:@"Now"] doubleValue];
                        double open = [[_service getCurrentIndicateWithCode:self.code andName:@"Open"] doubleValue];
                        double high = [[_service getCurrentIndicateWithCode:self.code andName:@"High"] doubleValue];
                        double low = [[_service getCurrentIndicateWithCode:self.code andName:@"Low"] doubleValue];
                        unsigned long volume = [[_service getCurrentIndicateWithCode:self.code andName:@"Volume"] unsignedLongValue];

                        BDKLine *lastLine = [self.lines lastObject];
                        if (lastLine && lastLine.date == date) {
                            lastLine.high = high;
                            lastLine.open = open;
                            lastLine.low = low;
                            lastLine.close = price;
                            lastLine.volume = volume;
                        }
                        else {
                            BDKLine *newLine = [[BDKLine alloc] init];
                            newLine.date = date;
                            newLine.high = high;
                            newLine.open = open;
                            newLine.low = low;
                            newLine.close = price;
                            newLine.volume = volume;
                            [self.lines addObject:newLine];
                        }
                        
                        [self setValue:self.lines forKey:@"lines"];  // kvo
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"KLineChartViewModel 订阅指标数据异常：%@", [exception reason]);
                }
            }
        });
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SOCKET_CONNECT object:nil];
    [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
    NSLog(@"KLineChartViewModel dealloc (%@)", self.code);
}

@end
