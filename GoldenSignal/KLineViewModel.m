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
#define IndicaterNames @[@"Date", @"Now", @"Open", @"High", @"Low", @"Volume"]

@interface KLineViewModel()

@property(nonatomic, strong) NSMutableArray *allLines;
@property(nonatomic, strong) BDKLine *tmpLine;

@end

@implementation KLineViewModel

- (instancetype)initWithCode:(NSString *)code kLineType:(KLineType)type andNumber:(NSUInteger)number {
    self = [super init];
    if (self) {
        _code = code;
        _displayNum = number;
        _type = type;
        
        if (_code) {
            [self setSignal];
        }
    }
    return self;
}

#pragma mark - Property

// 价格区间
- (PriceRange)priceRange {
    double maxPrice = 0;
    double minPrice = 0;
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
- (unsigned long)maxTrdVol {
    unsigned long max = 0;
    for (BDKLine *kLine in _lines) {
        if (kLine.volume > max) {
            max = kLine.volume;
        }
    }
    return max;
}


#pragma mark Method

// 计算均价
- (double)calcAvgPriceForDate:(NSUInteger)date andMA:(NSUInteger)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"date <= %lu", date]];
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[self.allLines filteredArrayUsingPredicate:predicate]];
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

- (void)setSignal {
    BDQuotationService *service = [BDQuotationService sharedInstance];
    self.tmpLine = [BDKLine new];
    
    @weakify(self);
    RACSignal *initSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[[service kLineSignalWithCode:self.code forType:self.type andNumber:self.displayNum + ExtraLines] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *values) {
            @strongify(self);
            self.allLines = [self paraseTrendLines:values];
            [subscriber sendNext:@(YES)];
            [subscriber sendCompleted];
        } error:^(NSError *error) {
            [subscriber sendError:nil];
        }];
        return nil;
    }];
    
    RACSignal *updateSignal = [[RACSignal combineLatest:@[[service scalarSignalWithCode:self.code andIndicater:@"Date"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Now"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Open"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"High"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Low"],
                                                          [service scalarSignalWithCode:self.code andIndicater:@"Volume"]
                                                          ]] map:^id(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(NSNumber *date, NSNumber *now, NSNumber *open, NSNumber *high, NSNumber *low, NSNumber *volume) = tuple;
        self.tmpLine.date = [date unsignedIntValue];
        self.tmpLine.high = [high doubleValue];
        self.tmpLine.open = [open doubleValue];
        self.tmpLine.low = [low doubleValue];
        self.tmpLine.close = [now doubleValue];
        self.tmpLine.volume = [volume unsignedLongValue];
        return @(YES);
    }];
    
    [[[RACSignal combineLatest:@[initSignal, updateSignal]] takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(id initFlag, id updateFlag) = tuple;
        if (initFlag && updateFlag) {
//            NSLog(@"Signal: 更新K线数据(%@)", self.code);
            [self updateKLine];
        }
    } error:^(NSError *error) {
        @strongify(self);
        NSLog(@"Signal: 获取历史K线数据失败(%@)", self.code);
    }];
}

- (void)updateKLine {
    BDKLine *lastLine = [self.allLines lastObject];
    switch (_type) {
        case KLINE_DAY:
            if (lastLine && lastLine.date == self.tmpLine.date) {
                lastLine.high = self.tmpLine.high;
                lastLine.open = self.tmpLine.open;
                lastLine.low = self.tmpLine.low;
                lastLine.close = self.tmpLine.close;
                lastLine.volume = self.tmpLine.volume;
            }
            else {
                [self.allLines addObject:[self.tmpLine copy]];
            }
            break;
        case KLINE_WEEK:
            if (lastLine && [self inSameWeekWithDate:lastLine.date andDate:self.tmpLine.date]) {
                if (self.tmpLine.high > lastLine.high) {
                    lastLine.high = self.tmpLine.high;
                }
                if (self.tmpLine.low < lastLine.low) {
                    lastLine.low = self.tmpLine.low;
                }
                lastLine.close = self.tmpLine.close;
                lastLine.date = self.tmpLine.date;
            }
            else {
                [self.allLines addObject:[self.tmpLine copy]];
            }
        case KLINE_MONTH:
            if (lastLine && [self inSameMonthWithDate:lastLine.date andDate:self.tmpLine.date]) {
                if (self.tmpLine.high > lastLine.high) {
                    lastLine.high = self.tmpLine.high;
                }
                if (self.tmpLine.low < lastLine.low) {
                    lastLine.low = self.tmpLine.low;
                }
                lastLine.close = self.tmpLine.close;
                lastLine.date = self.tmpLine.date;
            }
            else {
                [self.allLines addObject:[self.tmpLine copy]];
            }
    }
    
    NSRange range = self.allLines.count > _displayNum ? NSMakeRange(self.allLines.count - _displayNum, _displayNum) : NSMakeRange(0, self.allLines.count);
    NSArray *lines = [self.allLines subarrayWithRange:range];
    [self setValue:lines forKey:@"lines"];
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
    [[BDQuotationService sharedInstance] unsubscribeScalarWithCode:self.code indicaters:IndicaterNames];
//    NSLog(@"KLineViewModel dealloc (%@)", self.code);
}

@end
