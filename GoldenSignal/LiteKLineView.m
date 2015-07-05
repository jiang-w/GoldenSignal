//
//  LiteKLineView.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "LiteKLineView.h"
#import "KLineViewModel_old.h"

@implementation LiteKLineView
{
    KLineViewModel_old *_vm;
    int _number;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        lineFrame = CGRectMake(1, 1, CGRectGetWidth(self.frame)-2, CGRectGetHeight(self.frame)-2);
        
        if (code) {
            _code = [code copy];
            _number = 5;
            _vm = [[KLineViewModel_old alloc] initWithCode:code];
            [_vm loadKLineWithType:KLINE_DAY andNumber:_number];
            [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
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
        [self drawKLine];
    }
    @catch (NSException *exception) {
        NSLog(@"绘制分时线异常");
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

- (void)drawKLine {
    PriceRange priceRange = _vm.priceRange;
    if (priceRange.high - priceRange.low == 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
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


#pragma mark - Dealloc

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"lines"];
}

@end
