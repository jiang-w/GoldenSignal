//
//  IdxTrendView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxTrendChart.h"
#import "TrendLineChartViewModel.h"

@interface IdxTrendChart()

@property (nonatomic, strong) NSMutableArray* layers;
@property (nonatomic, strong) NSString *code;

@end

@implementation IdxTrendChart
{
    TrendLineChartViewModel *_vm;
}

- (id)initWithFrame:(CGRect)frame andIdxCode:(NSString *)code
{
    self = [super initWithFrame:frame];
    if (self) {
        _vm = [[TrendLineChartViewModel alloc] init];
        _code = code;
        _layers = [NSMutableArray array];
        [self setDefaultParameters];
        
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm addObserver:self forKeyPath:@"prevClose" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm loadDataWithSecuCode:_code forDays:1 andInterval:1];
    }
    return self;
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

- (CGRect)lineChartFrame {
    CGPoint origin = CGPointMake(_margin, _margin);
    CGFloat width = CGRectGetWidth(self.frame) - _margin * 2;
    CGFloat height = CGRectGetHeight(self.frame) - _margin * 2;
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    return rect;
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
            NSLog(@"IdxTrendChart 绘制指数走势线异常: %@", exception.reason);
        }
    });
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
    CGRect lineChartRect = [self lineChartFrame];
    CGContextAddRect(ctx, lineChartRect);
    CGContextStrokePath(ctx);
    
    // draw grid
    if(_drawInnerGrid) {
        CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
        CGContextSetLineWidth(ctx, _innerGridLineWidth);
        CGContextSetLineDash(ctx, 0, (CGFloat[]){1, 2}, 2);
        
        for(int i = 1; i < _horizontalGridStep; i++) {
            CGPoint point = CGPointMake(i * CGRectGetWidth(lineChartRect) / _horizontalGridStep + _margin, _margin);
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, CGRectGetMaxY(lineChartRect));
            CGContextStrokePath(ctx);
        }
        
        for(int i = 1; i < _verticalGridStep; i++) {
            CGPoint point = CGPointMake(_margin, i * CGRectGetHeight(lineChartRect) / _verticalGridStep + _margin);
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(lineChartRect), point.y);
            CGContextStrokePath(ctx);
        }
    }
}

- (void)strokeLineChart {
    NSString *date = [_vm.dates firstObject];
    CGRect chartFrame = [self lineChartFrame];
    
    // 绘制日分时线
    CGPathRef linePath = [self getPricePathInFrame:chartFrame forTradingDay:date andIsClosed:NO];
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bounds;
    pathLayer.path = linePath;
    pathLayer.strokeColor = [_color CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = _lineWidth;
    pathLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:pathLayer];
    [self.layers addObject:pathLayer];
    // 填充
    if(_fillColor && _fillColor != [UIColor clearColor]) {
        CGPathRef fillPath = [self getPricePathInFrame:chartFrame forTradingDay:date andIsClosed:YES];
        CAShapeLayer* fillLayer = [CAShapeLayer layer];
        fillLayer.frame = self.bounds;
        fillLayer.path = fillPath;
        fillLayer.strokeColor = nil;
        fillLayer.fillColor = _fillColor.CGColor;
        fillLayer.lineWidth = 0;
        fillLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:fillLayer];
        [self.layers addObject:fillLayer];
    }
}

- (CGPathRef)getPricePathInFrame:(CGRect)frame forTradingDay:(NSString *)date andIsClosed:(BOOL)closed {
    NSArray *points = [_vm getPricePointInFrame:frame forTradingDay:date];
    UIBezierPath* path = [UIBezierPath bezierPath];
    if (points.count > 0) {
        for (int i = 0; i < points.count; i++) {
            if(i > 0) {
                [path addLineToPoint:CGPointFromString(points[i])];
            }
            else {
                [path moveToPoint:CGPointFromString(points[i])];
            }
        }
        
        if(closed) {
            CGPoint lastPoint = CGPointFromString([points lastObject]);
            CGPoint lPoint = CGPointMake(lastPoint.x, CGRectGetMaxY(frame));
            [path addLineToPoint:lPoint];
            CGPoint fristPoint = CGPointFromString([points firstObject]);
            CGPoint fPoint = CGPointMake(fristPoint.x, CGRectGetMaxY(frame));
            [path addLineToPoint:fPoint];
            [path addLineToPoint:fristPoint];
        }
    }
    return path.CGPath;
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
