//
//  TrendLineChart.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TrendLineChart.h"
#import "TrendLineChartViewModel.h"

@interface TrendLineChart()

@property (nonatomic, strong) NSMutableArray* layers;

@end

@implementation TrendLineChart
{
    TrendLineChartViewModel *_vm;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _vm = [[TrendLineChartViewModel alloc] init];
        _layers = [NSMutableArray array];
        [self setDefaultParameters];
        
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm addObserver:self forKeyPath:@"prevClose" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)setMargin:(CGFloat)value {
    _margin = value;
    _margin_top = value;
    _margin_left = value;
    _margin_right = value;
    _margin_bottom = value;
}

- (CGRect)lineChartFrame {
    CGPoint origin = CGPointMake(_margin_left, _margin_top);
    CGFloat width = CGRectGetWidth(self.frame) - _margin_left - _margin_right;
    CGFloat height = (CGRectGetHeight(self.frame) - _margin_top - _margin_bottom - _space) / 3.0 * 2;
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    return rect;
}

- (CGRect)volumeChartFrame {
    CGRect lineChartRect = [self lineChartFrame];
    CGPoint origin = CGPointMake(CGRectGetMinX(lineChartRect), CGRectGetMaxY(lineChartRect) + _space);
    CGFloat width = CGRectGetWidth(lineChartRect);
    CGFloat height = CGRectGetHeight(self.frame) - _margin_bottom - origin.y;
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    return rect;
}

- (void)setDefaultParameters {
    self.margin = 0.0f;
    self.space = 4.0f;
    
    _lineColor = [UIColor whiteColor];
    _fillColor = [UIColor clearColor];
    _lineWidth = 1;
    
    _boundColor = [UIColor colorWithWhite:1 alpha:1.0];
    _boundWidth = 0.5;
    
    _innerGridColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _innerGridWidth = 0.5;
    _drawInnerGrid = YES;
    
    _days = 1;
    _interval = 1;
}

- (void)loadDataWithSecuCode:(NSString *)code {
    [_vm loadDataWithSecuCode:code forDays:_days andInterval:_interval];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            if (_vm.lines.count > 0 && _vm.prevClose > 0) {
                [self clearLayers];
                [self strokeLineChart];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"绘制指数走势线异常: %@", exception.reason);
        }
    });
}

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
}

- (void)drawGrid {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, _boundWidth);
    CGContextSetStrokeColorWithColor(ctx, [_boundColor CGColor]);

    // draw bound
    CGRect lineChartRect = [self lineChartFrame];
    CGRect volumeChartRect = [self volumeChartFrame];
    CGContextAddRect(ctx, lineChartRect);
    CGContextStrokePath(ctx);
    CGContextAddRect(ctx, volumeChartRect);
    CGContextStrokePath(ctx);
    
    // draw grid
    if(_drawInnerGrid) {
        CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
        CGContextSetLineWidth(ctx, _innerGridWidth);
        CGContextSetLineDash(ctx, 0, (CGFloat[]){4, 4}, 2);
        
        NSInteger horizontalGridStep = _days > 1 ? _days : 4;
        for(int i = 1; i < horizontalGridStep; i++) {
            CGPoint point = CGPointMake(i * CGRectGetWidth(lineChartRect) / horizontalGridStep + CGRectGetMinX(lineChartRect), CGRectGetMinY(lineChartRect));
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, point.y + CGRectGetHeight(lineChartRect));
            
            point = CGPointMake(i * CGRectGetWidth(volumeChartRect) / horizontalGridStep + CGRectGetMinX(volumeChartRect), CGRectGetMinY(volumeChartRect));
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, point.y + CGRectGetHeight(volumeChartRect));
            CGContextStrokePath(ctx);
        }

        int verticalGridStep = 4;
        for(int i = 1; i < verticalGridStep; i++) {
            CGPoint point = CGPointMake(CGRectGetMinX(lineChartRect), i * CGRectGetHeight(lineChartRect) / verticalGridStep + CGRectGetMinY(lineChartRect));
            if (i%2 == 0) {
                // 画实线
                CGContextSetLineDash (ctx, 0, 0, 0);
            }
            else {
                // 画虚线
                CGContextSetLineDash(ctx, 0, (CGFloat[]){4, 4}, 2);
            }
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x + CGRectGetWidth(lineChartRect), point.y);
            CGContextStrokePath(ctx);
        }
    }
}

- (void)strokeLineChart {
    NSArray *dates = _vm.dates;
    CGRect chartFrame = [self lineChartFrame];
    CGFloat xOffset = CGRectGetWidth(chartFrame) / dates.count;
    for (int i = 0; i < dates.count; i++) {
        int date = [[dates[i] stringByReplacingOccurrencesOfString:@"-" withString:@""] intValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %d", date];
        NSArray *lines = [_vm.lines filteredArrayUsingPredicate:predicate];
        CGRect frame = CGRectMake(chartFrame.origin.x + xOffset * i, chartFrame.origin.y, xOffset, chartFrame.size.height);
        UIBezierPath *linePath = [self getDailyLinePathInFrame:frame withLines:lines andIsClosed:NO];
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = self.bounds;
        pathLayer.path = linePath.CGPath;
        pathLayer.strokeColor = [_lineColor CGColor];
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = _lineWidth;
        pathLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:pathLayer];
        [self.layers addObject:pathLayer];
        
        if(_fillColor && _fillColor != [UIColor clearColor]) {
            UIBezierPath *fillPath = [self getDailyLinePathInFrame:frame withLines:lines andIsClosed:YES];
            CAShapeLayer* fillLayer = [CAShapeLayer layer];
            fillLayer.frame = self.bounds;
            fillLayer.path = fillPath.CGPath;
            fillLayer.strokeColor = nil;
            fillLayer.fillColor = _fillColor.CGColor;
            fillLayer.lineWidth = 0;
            fillLayer.lineJoin = kCALineJoinRound;
            [self.layer addSublayer:fillLayer];
            [self.layers addObject:fillLayer];
        }
    }
}

- (UIBezierPath*)getDailyLinePathInFrame:(CGRect)frame withLines:(NSArray *)lines andIsClosed:(BOOL)closed {
    NSMutableArray *temp = [NSMutableArray array];      // 存放分时线点
    BDTrendLine *prevLine = nil;
    CGPoint point;
    for (BDTrendLine *line in _vm.lines) {
        int sn = [_vm getSerialNumberWithTime:line.time];
        if (prevLine == nil) {
            if (sn != 0) {
                point = [_vm getPointInFrame:frame withSerialNumber:0 andPrice:line.price];
                [temp addObject:NSStringFromCGPoint(point)];
            }
        }
        else {
            if (sn > 0) {
                int prevTime = [_vm getTimeWithSerialNumber:sn-1];
                if (prevTime > prevLine.time) {
                    point = [_vm getPointInFrame:frame withSerialNumber:sn-1 andPrice:prevLine.price];
                    [temp addObject:NSStringFromCGPoint(point)];
                }
            }
        }
        point = [_vm getPointInFrame:frame withSerialNumber:sn andPrice:line.price];
        [temp addObject:NSStringFromCGPoint(point)];
        prevLine = line;
    }
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    if (temp.count > 0) {
        /* 绘制分时线 */
        
        for (int i = 0; i < temp.count; i++) {
            if(i > 0) {
                [path addLineToPoint:CGPointFromString(temp[i])];
            }
            else {
                [path moveToPoint:CGPointFromString(temp[i])];
            }
        }
        
        if(closed) {
            CGPoint lastPoint = CGPointFromString([temp lastObject]);
            CGPoint lPoint = CGPointMake(lastPoint.x, CGRectGetMaxY(frame));
            [path addLineToPoint:lPoint];
            CGPoint fristPoint = CGPointFromString([temp firstObject]);
            CGPoint fPoint = CGPointMake(fristPoint.x, CGRectGetMaxY(frame));
            [path addLineToPoint:fPoint];
            [path addLineToPoint:fristPoint];
        }
    }
    return path;
}


- (void)clearLayers
{
    for (CAShapeLayer *layer in self.layers) {
        [layer removeFromSuperlayer];
    }
    [self.layers removeAllObjects];
}

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"lines"];
    [_vm removeObserver:self forKeyPath:@"prevClose"];
}

@end