//
//  TrendLineViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TrendLineViewModel.h"
#import "BDQuotationService.h"
#import "BDTradingDayService.h"

#define IndicaterNames @[@"Date", @"Time", @"Now", @"Amount", @"Volume", @"PrevClose"]

@interface TrendLineViewModel()

@property(nonatomic, strong) BDTrendLine *tmpLine;

@end

@implementation TrendLineViewModel

- (instancetype)initWithCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval {
    self = [super init];
    if (self) {
        _code = code;
        _days = days;
        _interval = interval;
        
        if (_code) {
            [self setSignal];
        }
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

- (unsigned long)maxVolume {
    NSMutableArray *volumeArr = [NSMutableArray array];
    NSArray *dates = self.tradingDays;
    for (NSString *date in dates) {
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

- (NSArray *)tradingDays {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    NSString *dateString = nil;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    if ([timeString intValue] > 93000) {
        dateString = [formatter stringFromDate:[NSDate date]];
    }
    else {
        dateString = [formatter stringFromDate:[[NSDate date] addDays:-1]];
    }
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[BDTradingDayService getTradingDaysToDate:dateString forDays:self.days]];
    [arr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    return arr;
}


#pragma mark Subscribe

- (void)setSignal {
    BDQuotationService *service = [BDQuotationService sharedInstance];
    self.tmpLine = [BDTrendLine new];
    
    @weakify(self);
    RACSignal *initSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[[service trendLineWithCode:self.code forDays:self.days andInterval:self.interval] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *values) {
            @strongify(self);
            self.lines = [self paraseTrendLines:values];
            [subscriber sendNext:@(YES)];
            [subscriber sendCompleted];
        } error:^(NSError *error) {
            [subscriber sendError:nil];
        }];
        return nil;
    }];

    RACSignal *updateSignal = [[RACSignal combineLatest:@[[service scalarSignalWithCode:self.code andIndicater:@"Date"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Time"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Now"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Amount"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Volume"]
                                                          ]] map:^id(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(NSNumber *date, NSNumber *time, NSNumber *now, NSNumber *amount, NSNumber *volume) = tuple;
        self.tmpLine.date = [date unsignedIntValue];
        self.tmpLine.time = [time unsignedIntValue] / 100000;
        self.tmpLine.price = [now doubleValue];
        self.tmpLine.amount = [amount doubleValue];
        self.tmpLine.volume = [volume unsignedLongValue];
        return @(YES);
    }];
    
    [[[RACSignal combineLatest:@[initSignal, updateSignal]] takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(id initFlag, id updateFlag) = tuple;
        if (initFlag && updateFlag) {
//            NSLog(@"Signal: 更新走势线数据(%@)", self.code);
            [self updateTrendLine];
        }
    } error:^(NSError *error) {
        @strongify(self);
        NSLog(@"Signal: 获取历史走势线数据失败(%@)", self.code);
    }];
    // 昨收价
    RAC(self, prevClose) = [service scalarSignalWithCode:self.code andIndicater:@"PrevClose"];
    // 连接socket后重新订阅历史数据
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:QUOTE_SOCKET_CONNECT object:nil] subscribeNext:^(id x) {
        [initSignal subscribeNext:^(id x) {
            
        }];
    }];
}

- (void)updateTrendLine {
    unsigned int mergeMinute = [self mergeMinuteWithTime:self.tmpLine.time];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %lu", self.tmpLine.date];
    NSMutableArray *lineArray = [NSMutableArray arrayWithArray:[self.lines filteredArrayUsingPredicate:predicate]];
    [lineArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
    BDTrendLine *line = [lineArray firstObject];
    if (line == nil || mergeMinute > line.time) {
        line = [[BDTrendLine alloc] init];
        line.date = self.tmpLine.date;
        line.time = mergeMinute;
        [self.lines addObject:line];
    }
    line.price = self.tmpLine.price;
    line.amount = self.tmpLine.amount;
    line.volume = self.tmpLine.volume;
    
    [self setValue:self.lines forKey:@"lines"];
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

- (NSMutableArray *)paraseTrendLines:(NSArray *)data {
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
        if (volume != 0) {
            CGPoint point = [self getPointInFrame:frame withScale:scale andValue:volume serialNumber:i];
            [points addObject:NSStringFromCGPoint(point)];
        }
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
        if (serial.count == 0) {
            serial[0] = [NSNumber numberWithDouble:line.price];
        }
        int sn = [self getSerialNumberWithTime:line.time];
        while (serial.count < sn) {
            serial[serial.count] = serial[serial.count - 1];
        }
        serial[sn] = [NSNumber numberWithDouble:line.price];
        i++;
    }
    return serial;
}

// 获取某交易日的均价序列（日期格式'yyyy-MM-dd'）
- (NSArray *)getAvgPriceSerialForTradingDay:(NSString *)date {
    NSMutableArray *serial = [NSMutableArray array];
    int dateVal = [[date stringByReplacingOccurrencesOfString:@"-" withString:@""] intValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %d", dateVal];
    NSArray *lines = [_lines filteredArrayUsingPredicate:predicate];
    
    int i = 0;
    while (i < lines.count) {
        BDTrendLine *line = lines[i];
        if (serial.count == 0) {
            serial[0] = [NSNumber numberWithDouble:line.amount / line.volume];
        }
        int sn = [self getSerialNumberWithTime:line.time];
        while (serial.count < sn) {
            serial[serial.count] = serial[serial.count - 1];
        }
        serial[sn] = [NSNumber numberWithDouble:line.amount / line.volume];
        i++;
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
    [[BDQuotationService sharedInstance] unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
//    NSLog(@"TrendLineViewModel dealloc (%@)", self.code);
}


@end
