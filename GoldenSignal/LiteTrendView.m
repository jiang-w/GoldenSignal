//
//  LiteTrendView.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "LiteTrendView.h"
#import "TrendLineViewModel.h"

@implementation LiteTrendView
{
    TrendLineViewModel *_vm;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        lineFrame = CGRectMake(1, 1, CGRectGetWidth(self.frame)-2, CGRectGetHeight(self.frame)-2);
        
        if (code) {
            _code = [code copy];
            _vm = [[TrendLineViewModel alloc] initWithCode:code];
            [_vm addObserver:self forKeyPath:@"priceRange" options:NSKeyValueObservingOptionNew context:NULL];
            [_vm loadTrendLineForDays:1 andInterval:5];
        }
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

#pragma mark - Draw View

- (void)drawRect:(CGRect)rect {
    @try {
        [self drawGrid];
        if (_vm.lines.count > 0 && _vm.prevClose > 0) {
            [self drawDayLineInFrame:lineFrame withLines:_vm.lines];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"绘制分时线异常: %@", exception.reason);
    }
}

// 绘制网格
- (void)drawGrid {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextMoveToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame));
    CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame));
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextMoveToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame));
    CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMaxY(lineFrame));
    CGContextStrokePath(context);
}

// 绘制日分时线
- (void)drawDayLineInFrame:(CGRect)frame withLines:(NSArray *)lines {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineDash (context, 0, 0, 0);
    CGContextSetLineWidth(context, 1);
    
    NSMutableArray *temp = [NSMutableArray array];      // 存放分时线点
    BDTrendLine *prevLine = nil;
    CGPoint point;
    for (BDTrendLine *line in lines) {
        int sn = [_vm getSerialNumberWithTime:line.time];
        if (prevLine == nil) {
            if (sn != 0) {
                point = [_vm getPointInFrame:frame WithSerialNumber:0 andPrice:line.price];
                [temp addObject:NSStringFromCGPoint(point)];
            }
        }
        else {
            if (sn > 0) {
                int prevTime = [_vm getTimeWithSerialNumber:sn-1];
                if (prevTime > prevLine.time) {
                    point = [_vm getPointInFrame:frame WithSerialNumber:sn-1 andPrice:prevLine.price];
                    [temp addObject:NSStringFromCGPoint(point)];
                }
            }
        }
        point = [_vm getPointInFrame:frame WithSerialNumber:sn andPrice:line.price];
        [temp addObject:NSStringFromCGPoint(point)];
        prevLine = line;
    }
    
    /* 绘制分时线 */
    CGPoint points[temp.count];
    for (int i = 0; i < temp.count; i++) {
        points[i] = CGPointFromString(temp[i]);
    }
    CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
    CGContextAddLines(context, points, temp.count);
    CGContextDrawPath(context, kCGPathStroke);
}


#pragma mark - Dealloc

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"priceRange"];
}

@end
