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
        [self setDefaultParameters];
        _vm = [[TrendLineChartViewModel alloc] initWithCode:@"000001.SHI"];
        [_vm loadTrendLineForDays:1 andInterval:1];
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

- (CGRect)lineChartRect {
    CGPoint origin = CGPointMake(_margin_left, _margin_top);
    CGFloat width = CGRectGetWidth(self.frame) - _margin_left - _margin_right;
    CGFloat height = (CGRectGetHeight(self.frame) - _margin_top - _margin_bottom - _space) / 3.0 * 2;
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    return rect;
}

- (CGRect)volumeChartRect {
    CGRect lineChartRect = [self lineChartRect];
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
    CGRect lineChartRect = [self lineChartRect];
    CGRect volumeChartRect = [self volumeChartRect];
    CGContextAddRect(ctx, lineChartRect);
    CGContextStrokePath(ctx);
    CGContextAddRect(ctx, volumeChartRect);
    CGContextStrokePath(ctx);
    
    // draw grid
    if(_drawInnerGrid) {
        CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
        CGContextSetLineWidth(ctx, _innerGridWidth);
        CGContextSetLineDash(ctx, 0, (CGFloat[]){4, 4}, 2);
        
        int horizontalGridStep = 4;
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

//- (void)strokeLineChart
//{
//    CGFloat minBound = _vm.priceRange.low;
//    CGFloat maxBound = _vm.priceRange.high;
//    CGFloat scale = CGRectGetHeight([self lineChartRect]) / (maxBound - minBound);
//    
//    UIBezierPath *linePath = [self getLinePath:scale close:NO];
//    CAShapeLayer *pathLayer = [CAShapeLayer layer];
//    pathLayer.frame = self.bounds;
//    pathLayer.path = linePath.CGPath;
//    pathLayer.strokeColor = [_lineColor CGColor];
//    pathLayer.fillColor = nil;
//    pathLayer.lineWidth = _lineWidth;
//    pathLayer.lineJoin = kCALineJoinRound;
//    
//    [self.layer addSublayer:pathLayer];
//    [self.layers addObject:pathLayer];
//    
//    if(_fillColor) {
//        UIBezierPath *fillPath = [self getLinePath:scale close:YES];
//        CAShapeLayer* fillLayer = [CAShapeLayer layer];
//        fillLayer.frame = self.bounds;
//        fillLayer.path = fillPath.CGPath;
//        fillLayer.strokeColor = nil;
//        fillLayer.fillColor = _fillColor.CGColor;
//        fillLayer.lineWidth = 0;
//        fillLayer.lineJoin = kCALineJoinRound;
//        
//        [self.layer addSublayer:fillLayer];
//        [self.layers addObject:fillLayer];
//    }
//}

//- (UIBezierPath*)getLinePath:(float)scale close:(BOOL)closed
//{
//    CGRect frame = [CGPointMake(_margin_left, _margin_top), [self lineChartRect]];
//    NSMutableArray *temp = [NSMutableArray array];      // 存放分时线点
//    BDTrendLine *prevLine = nil;
//    CGPoint point;
//    for (BDTrendLine *line in _vm.lines) {
//        int sn = [_vm getSerialNumberWithTime:line.time];
//        if (prevLine == nil) {
//            if (sn != 0) {
//                point = [_vm getPointInFrame:frame WithSerialNumber:0 andPrice:line.price];
//                [temp addObject:NSStringFromCGPoint(point)];
//            }
//        }
//        else {
//            if (sn > 0) {
//                int prevTime = [_vm getTimeWithSerialNumber:sn-1];
//                if (prevTime > prevLine.time) {
//                    point = [_vm getPointInFrame:frame WithSerialNumber:sn-1 andPrice:prevLine.price];
//                    [temp addObject:NSStringFromCGPoint(point)];
//                }
//            }
//        }
//        point = [_vm getPointInFrame:frame WithSerialNumber:sn andPrice:line.price];
//        [temp addObject:NSStringFromCGPoint(point)];
//        prevLine = line;
//    }
//    
//    UIBezierPath* path = [UIBezierPath bezierPath];
//    if (temp.count > 0) {
//        /* 绘制分时线 */
//        
//        for (int i = 0; i < temp.count; i++) {
//            if(i > 0) {
//                [path addLineToPoint:CGPointFromString(temp[i])];
//            }
//            else {
//                [path moveToPoint:CGPointFromString(temp[i])];
//            }
//        }
//        
//        if(closed) {
//            CGPoint lastPoint = CGPointFromString([temp lastObject]);
//            CGPoint lPoint = CGPointMake(lastPoint.x, _margin + self.chartHeight);
//            [path addLineToPoint:lPoint];
//            CGPoint fristPoint = CGPointFromString([temp firstObject]);
//            CGPoint fPoint = CGPointMake(fristPoint.x, _margin + self.chartHeight);
//            [path addLineToPoint:fPoint];
//            [path addLineToPoint:fristPoint];
//        }
//    }
//    return path;
//}


- (void)clearLayers
{
    for (CAShapeLayer *layer in self.layers) {
        [layer removeFromSuperlayer];
    }
    [self.layers removeAllObjects];
}

//- (void)dealloc {
//    [_vm removeObserver:self forKeyPath:@"priceRange"];
//}

@end
