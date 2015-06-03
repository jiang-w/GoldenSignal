//
//  IdxTrendView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxTrendChart.h"
#import "TrendLineViewModel.h"

@interface IdxTrendChart()

@property (nonatomic, strong) NSMutableArray* layers;
@property (nonatomic, strong) NSString *code;

@end

@implementation IdxTrendChart
{
    TrendLineViewModel *_vm;
}

- (id)initWithFrame:(CGRect)frame andIdxCode:(NSString *)code
{
    self = [super initWithFrame:frame];
    if (self) {
        _code = code;
        [self commonInit];
        
        _vm = [[TrendLineViewModel alloc] initWithCode:_code];
        [_vm addObserver:self forKeyPath:@"priceRange" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm loadTrendLineForDays:1 andInterval:5];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [self drawGrid];
            if (_vm.lines.count > 0 && _vm.prevClose > 0) {
                [self clearLayers];
                [self strokeChart];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"绘制指数走势线异常: %@", exception.reason);
        }
    });
}

- (void)commonInit
{
    _layers = [NSMutableArray array];
    self.backgroundColor = [UIColor clearColor];
    [self setDefaultParameters];
}

- (void)setDefaultParameters
{
    _color = [UIColor orangeColor];
    _fillColor = [_color colorWithAlphaComponent:0.15];
    _lineWidth = 1;
    _margin = 0.0f;
    
    _verticalGridStep = 2;
    _horizontalGridStep = 4;
    
    _boundColor = [UIColor colorWithWhite:1 alpha:1.0];
    _boundLineWidth = 0.5;
    _innerGridColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _innerGridLineWidth = 0.5;
    _drawInnerGrid = YES;
}

- (CGFloat)chartWidth {
    return self.frame.size.width - 2 * _margin;
}

- (CGFloat)chartHeight {
    return self.frame.size.height - 2 * _margin;
}

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
}

- (void)drawGrid
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, _boundLineWidth);
    CGContextSetStrokeColorWithColor(ctx, [_boundColor CGColor]);
    
    // draw bound
    CGContextMoveToPoint(ctx, _margin, _margin);
    CGContextAddLineToPoint(ctx, _margin, self.chartHeight + _margin);
    CGContextAddLineToPoint(ctx, self.chartWidth + _margin, self.chartHeight + _margin);
    CGContextAddLineToPoint(ctx, self.chartWidth + _margin, _margin);
    CGContextAddLineToPoint(ctx, _margin, _margin);
    CGContextStrokePath(ctx);
    
    // draw grid
    if(_drawInnerGrid) {
        CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
        CGContextSetLineWidth(ctx, _innerGridLineWidth);
        CGContextSetLineDash(ctx, 0, (CGFloat[]){1, 2}, 2);
        
        for(int i = 1; i < _horizontalGridStep; i++) {
            CGPoint point = CGPointMake(i * self.chartWidth / _horizontalGridStep + _margin, _margin);
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, point.y + self.chartHeight);
            CGContextStrokePath(ctx);
        }
        
        for(int i = 1; i < _verticalGridStep; i++) {
            CGPoint point = CGPointMake(_margin, (i) * self.chartHeight / _verticalGridStep + _margin);
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, self.chartWidth + _margin, point.y);
            CGContextStrokePath(ctx);
        }
    }
}

- (void)strokeChart
{
    CGFloat minBound = _vm.priceRange.low;
    CGFloat maxBound = _vm.priceRange.high;
    CGFloat scale = self.chartHeight / (maxBound - minBound);
    
    UIBezierPath *linePath = [self getLinePath:scale close:NO];
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bounds;
    pathLayer.path = linePath.CGPath;
    pathLayer.strokeColor = [_color CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = _lineWidth;
    pathLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:pathLayer];
    [self.layers addObject:pathLayer];
    
    if(_fillColor) {
        UIBezierPath *fillPath = [self getLinePath:scale close:YES];
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

- (UIBezierPath*)getLinePath:(float)scale close:(BOOL)closed
{
    CGRect frame = CGRectMake(_margin, _margin, self.chartWidth, self.chartHeight);
    NSMutableArray *temp = [NSMutableArray array];      // 存放分时线点
    BDTrendLine *prevLine = nil;
    CGPoint point;
    for (BDTrendLine *line in _vm.lines) {
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
            CGPoint lPoint = CGPointMake(lastPoint.x, _margin + self.chartHeight);
            [path addLineToPoint:lPoint];
            CGPoint fristPoint = CGPointFromString([temp firstObject]);
            CGPoint fPoint = CGPointMake(fristPoint.x, _margin + self.chartHeight);
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
    [_vm removeObserver:self forKeyPath:@"priceRange"];
}

@end
