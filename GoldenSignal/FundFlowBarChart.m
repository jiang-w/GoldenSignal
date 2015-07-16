//
//  FundFlowBarChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/16.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowBarChart.h"
#import "BarView.h"
#import "BDCoreService.h"

@implementation FundFlowBarChart
{
    NSUInteger _number;
    NSMutableArray *_valueArray;
    NSMutableArray *_dateArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _number = 0;
        _valueArray = [NSMutableArray array];
        _dateArray = [NSMutableArray array];
    }
    return self;
}

- (double)maxRange {
    NSComparator cmptr = ^(id obj1, id obj2){
        if (fabs([obj1 doubleValue]) > fabs([obj2 doubleValue])) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (fabs([obj1 doubleValue]) < fabs([obj2 doubleValue])) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *array = [_valueArray sortedArrayUsingComparator:cmptr];
    return fabs([[array lastObject] doubleValue]);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)loadDataWithCode:(NSString *)code andNumber:(NSUInteger)number {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *paramDic = @{@"BD_CODE": [NSString stringWithFormat:@"\'%@\'",code]};
        NSArray *data = [[BDCoreService new] syncRequestDatasourceService:1587 parameters:paramDic query:nil];
        _number = number;
        [_valueArray removeAllObjects];
        [_dateArray removeAllObjects];
        for (NSDictionary *item in data) {
            NSString *date = item[@"TRD_DT"];
            double value = [item[@"MNY_NET"] doubleValue];
            [_dateArray addObject:date];
            [_valueArray addObject:[NSNumber numberWithDouble:value]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}

- (void)addBars {
    double maxRange = [self maxRange];
    for (int i = 0; i < _valueArray.count && i < _number; i++) {
        float val = [_valueArray[i] floatValue];
        BarView *bar = [[BarView alloc] init];
        bar.grade = fabs(val) / maxRange;
        if (val > 0) {
            bar.color = [UIColor redColor];
        }
        else {
            bar.color = [UIColor greenColor];
        }
        [self addSubview:bar];
    }
}

@end
