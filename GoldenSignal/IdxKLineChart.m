//
//  IdxKLineChart.m
//  GoldenSignal
//
//  Created by Frank on 15/6/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxKLineChart.h"
#import "KLineViewModel.h"

@interface IdxKLineChart()

@property (nonatomic, strong) NSString *code;

@end

@implementation IdxKLineChart
{
    KLineViewModel *_vm;
    int _number;
}

- (id)initWithFrame:(CGRect)frame andIdxCode:(NSString *)code
{
    self = [super initWithFrame:frame];
    if (self) {
        _code = code;
        [self commonInit];
        
        _number = 40;
        _vm = [[KLineViewModel alloc] initWithCode:code];
        [_vm loadKLineWithType:KLINE_DAY andNumber:_number];
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    [self setDefaultParameters];
}

- (void)setDefaultParameters
{
    _margin = 0.0f;
    
    _verticalGridStep = 2;
    _horizontalGridStep = 1;
    
    _boundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
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
    @try {
        [self drawGrid];
        [self drawKLine];
    }
    @catch (NSException *exception) {
        NSLog(@"绘制指数分时线异常");
    }
}

- (void)drawGrid
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, _boundLineWidth);
    CGContextSetStrokeColorWithColor(ctx, [_boundColor CGColor]);
    CGContextSetLineDash (ctx, 0, 0, 0);
    
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

- (void)drawKLine {
    PriceRange priceRange = _vm.priceRange;
    if (priceRange.high - priceRange.low == 0) {
        return;
    }
    
    CGRect lineFrame = CGRectMake(_margin, _margin, self.chartWidth, self.chartHeight);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineDash (context, 0, 0, 0);
    float lineWidth = CGRectGetWidth(lineFrame) / _number;
    for (int i = 0; i < _vm.lines.count; i++) {
        BDKLine *kLine = _vm.lines[i];
        float xOffset = CGRectGetMinX(lineFrame) + lineWidth * (i + 1) - lineWidth / 2;
        float highYOffset = (priceRange.high - kLine.high) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        float lowYOffset = (priceRange.high - kLine.low) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        float openYOffset = (priceRange.high - kLine.open) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        float closeYOffset = (priceRange.high - kLine.close) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        if (kLine.open == kLine.close) {
            openYOffset += 0.5;
            closeYOffset -= 0.5;
        }
        
        // 设置蜡烛图的颜色
        if (kLine.open > kLine.close) { // 阴线
            CGContextSetStrokeColorWithColor(context, [RGB(35, 255, 238, 1) CGColor]);
        }
        else if (kLine.open < kLine.close) { // 阳线
            CGContextSetStrokeColorWithColor(context, [RGB(254, 0, 0, 1) CGColor]);
        }
        else {
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);  // 十字线
        }
        
        // 绘制影线
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, xOffset, highYOffset);
        CGContextAddLineToPoint(context, xOffset, lowYOffset);
        CGContextStrokePath(context);
        
        // 绘制实体
        CGContextSetLineWidth(context, lineWidth * 0.8);
        CGContextMoveToPoint(context, xOffset, openYOffset);
        CGContextAddLineToPoint(context, xOffset, closeYOffset);
        CGContextStrokePath(context);
    }
}


- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"lines"];
}

@end
