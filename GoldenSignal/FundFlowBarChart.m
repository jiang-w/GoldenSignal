//
//  FundFlowColumnChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/10.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowBarChart.h"

@implementation FundFlowBarChart
{
    NSMutableArray *_dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultParameters];
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)setDefaultParameters {
    self.margin_top = 0.0;
    self.margin_left = 0.0;
    self.margin_right = 0.0;
    self.margin_bottom = 0.0;
    
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - property


- (void)loadDataWithSecuCode:(NSString *)code {
    NSArray *data = nil;
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:data];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
}

@end
