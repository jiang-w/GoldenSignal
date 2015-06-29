//
//  LiteTrendView.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "LiteTrendView.h"
#import "TrendLineChartViewModel.h"

@interface LiteTrendView()

@property (nonatomic, strong) NSMutableArray* layers;
@property (nonatomic, strong) NSString *code;

@end

@implementation LiteTrendView
{
    TrendLineChartViewModel *_vm;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        _vm = [[TrendLineChartViewModel alloc] init];
        _code = code;
        _layers = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];

        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm addObserver:self forKeyPath:@"prevClose" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm loadDataWithSecuCode:_code forDays:1 andInterval:5];
    }
    return self;
}

- (CGRect)lineChartFrame {
    CGRect rect = CGRectMake(1, 1, CGRectGetWidth(self.frame)-2, CGRectGetHeight(self.frame)-2);
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
            NSLog(@"LiteTrendView 绘制走势线异常: %@", exception.reason);
        }
    });
}

#pragma mark - Draw View

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
}

// 绘制网格
- (void)drawGrid {
    CGRect lineFrame = [self lineChartFrame];
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

- (void)strokeLineChart {
    NSString *date = [_vm.dates firstObject];
    CGRect chartFrame = [self lineChartFrame];
    
    // 绘制日分时线
    CGPathRef linePath = [self getPricePathInFrame:chartFrame forTradingDay:date andIsClosed:NO];
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bounds;
    pathLayer.path = linePath;
    pathLayer.strokeColor = [[UIColor orangeColor] CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1;
    pathLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:pathLayer];
    [self.layers addObject:pathLayer];
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


#pragma mark - Dealloc

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"lines"];
    [_vm removeObserver:self forKeyPath:@"prevClose"];
}

@end
