//
//  LiteKLineView.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "LiteKLineView.h"
#import "KLineViewModel.h"

@interface LiteKLineView()

@property(nonatomic) CGRect lineChartFrame;
@property(nonatomic, strong) NSString *code;

@end

@implementation LiteKLineView
{
    KLineViewModel *_vm;
    int _number;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _code = code;
        _number = 5;
        _vm = [[KLineViewModel alloc] init];
        [_vm loadDataWithSecuCode:_code forType:KLINE_DAY andNumber:_number];
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
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
            [self setNeedsDisplay];
        }
        @catch (NSException *exception) {
            NSLog(@"LiteKLineView 绘制K线异常: %@", exception.reason);
        }
    });
}


#pragma mark - Draw View

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
    if (_vm.lines.count > 0) {
        [self strokeCandleChart];
    }
}

// 绘制网格
- (void)drawGrid {
    CGRect lineFrame = self.lineChartFrame;
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

- (void)strokeCandleChart {
    PriceRange priceRange = _vm.priceRange;
    NSRange range = _vm.lines.count > _number ? NSMakeRange(_vm.lines.count - _number, _number) : NSMakeRange(0, _vm.lines.count);
    NSArray *lines = [_vm.lines subarrayWithRange:range];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat lineWidth = CGRectGetWidth(self.lineChartFrame) / _number;
    for (int i = 0; i < lines.count; i++) {
        BDKLine *kLine = lines[i];
        float xOffset = CGRectGetMinX(self.lineChartFrame) + lineWidth * (i + 1) - lineWidth / 2;
        float highYOffset = (priceRange.high - kLine.high) / (priceRange.high - priceRange.low) * CGRectGetHeight(self.lineChartFrame) + CGRectGetMinY(self.lineChartFrame);
        float lowYOffset = (priceRange.high - kLine.low) / (priceRange.high - priceRange.low) * CGRectGetHeight(self.lineChartFrame) + CGRectGetMinY(self.lineChartFrame);
        float openYOffset = (priceRange.high - kLine.open) / (priceRange.high - priceRange.low) * CGRectGetHeight(self.lineChartFrame) + CGRectGetMinY(self.lineChartFrame);
        float closeYOffset = (priceRange.high - kLine.close) / (priceRange.high - priceRange.low) * CGRectGetHeight(self.lineChartFrame) + CGRectGetMinY(self.lineChartFrame);
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
//    NSLog(@"LiteKLineView dealloc (%@)", _code);
}

@end
