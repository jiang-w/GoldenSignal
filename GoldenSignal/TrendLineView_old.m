//
//  TrendLineView.m
//  CBNAPP
//
//  Created by Frank on 14/11/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "TrendLineView_old.h"
#import "TrendLineViewModel_old.h"
#import "MBProgressHUD/MBProgressHUD.h"

@implementation TrendLineView_old
{
    TrendLineViewModel_old *_vm;
    int _days;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        lineFrame = CGRectMake(1, 1, CGRectGetWidth(self.frame)-2, (CGRectGetHeight(self.frame)-2)/6.0*4);
        volumeFrame = CGRectMake(CGRectGetMinX(lineFrame)
                                 , CGRectGetMaxY(lineFrame)
                                 , CGRectGetWidth(lineFrame)
                                 , (CGRectGetHeight(self.frame)-2)/6.0*2-1);
        
        if (code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.opacity = 0;
            
            _code = [code copy];
            _days = 1;
            _vm = [[TrendLineViewModel_old alloc] initWithCode:code];
            [_vm addObserver:self forKeyPath:@"priceRange" options:NSKeyValueObservingOptionNew context:NULL];
            [_vm addObserver:self forKeyPath:@"maxVolume" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
        [MBProgressHUD hideHUDForView:self animated:YES];
    });
}


#pragma mark - Draw View

- (void)drawRect:(CGRect)rect {
    @try {
        [self drawGrid];
        [self drawLineAndVolume];
    }
    @catch (NSException *exception) {
        NSLog(@"绘制分时线异常: %@", exception.reason);
    }
}

// 绘制网格
- (void)drawGrid {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置画笔颜色和宽度
    CGContextSetStrokeColorWithColor(context, [RGB(80.0, 80.0, 80.0, 1.0) CGColor]);
    CGContextSetLineWidth(context, 1);
    
    // 绘制边框
    CGContextAddRect(context, lineFrame);
    CGContextAddRect(context, volumeFrame);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 绘制X虚线
    int regionCount = 4;
    CGFloat spacing = CGRectGetHeight(lineFrame) / regionCount;
    for (int i = 1; i < regionCount; i++) {
        CGFloat yOffset = CGRectGetMinY(lineFrame) + spacing * i;
        CGPoint startPoint = CGPointMake(CGRectGetMinX(lineFrame), yOffset);
        CGPoint endPoint = CGPointMake(CGRectGetMaxX(lineFrame), yOffset);
        if (i%2 == 0) {
            // 画实线
            CGContextSetLineDash (context, 0, 0, 0);
        }
        else {
            // 画虚线
            CGContextSetLineDash(context, 0, (CGFloat[]){4, 4}, 2);
        }
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    CGFloat midY = CGRectGetMidY(volumeFrame);
    CGContextMoveToPoint(context, CGRectGetMinX(volumeFrame), midY);
    CGContextAddLineToPoint(context, CGRectGetMaxX(volumeFrame), midY);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 绘制Y虚线
    CGContextSetLineDash(context, 0, (CGFloat[]){4, 4}, 2);
    regionCount = _days > 1 ? _days : 4;
    
    spacing = CGRectGetWidth(lineFrame) / regionCount;
    for (int i = 1; i < regionCount; i++) {
        CGFloat xOffset = CGRectGetMinX(lineFrame) + spacing * i;
        CGPoint startPoint = CGPointMake(xOffset, CGRectGetMinY(lineFrame));
        CGPoint endPoint = CGPointMake(xOffset, CGRectGetMaxY(lineFrame));
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    }
    
    spacing = CGRectGetWidth(volumeFrame) / regionCount;
    for (int i = 1; i < regionCount; i++) {
        CGFloat xOffset = CGRectGetMinX(volumeFrame) + spacing * i;
        CGPoint startPoint = CGPointMake(xOffset, CGRectGetMinY(volumeFrame));
        CGPoint endPoint = CGPointMake(xOffset, CGRectGetMaxY(volumeFrame));
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    // 绘制参考价格
    PriceRange priceRange = _vm.priceRange;
    spacing = self.frame.size.height / 6.0;
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    [fontAttributes setObject:[UIFont systemFontOfSize:9] forKey:NSFontAttributeName];
    for (int i = 0; i < 5; i++) {
        NSString *label;
        CGPoint point = CGPointMake(CGRectGetMinX(lineFrame) + 1, spacing * i);
        switch (i) {
            case 0: {
                float price = priceRange.high;
                float rate = _vm.prevClose != 0? (price - _vm.prevClose)/_vm.prevClose * 100.0 : 0.0;
                [fontAttributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
                label = [NSString stringWithFormat:@"%.2f", price];
                [label drawAtPoint:point withAttributes:fontAttributes];
                
                label = [NSString stringWithFormat:@"%.2f%%", rate];
                point.x = CGRectGetMaxX(lineFrame) - 28;
                [label drawAtPoint:point withAttributes:fontAttributes];
            }
                break;
            case 1: {
                float price = (priceRange.high + _vm.prevClose)/2.0;
                float rate = _vm.prevClose != 0? (price - _vm.prevClose)/_vm.prevClose * 100.0 : 0.0;
                [fontAttributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
                label = [NSString stringWithFormat:@"%.2f", price];
                [label drawAtPoint:point withAttributes:fontAttributes];
                
                label = [NSString stringWithFormat:@"%.2f%%", rate];
                point.x = CGRectGetMaxX(lineFrame) - 28;
                [label drawAtPoint:point withAttributes:fontAttributes];
            }
                break;
            case 2: {
                point.y -= 6;
                [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                label = [NSString stringWithFormat:@"%.2f", _vm.prevClose];
                [label drawAtPoint:point withAttributes:fontAttributes];
                
                label = [NSString stringWithFormat:@"%.2f%%", 0.0];
                point.x = CGRectGetMaxX(lineFrame) - 28;
                [label drawAtPoint:point withAttributes:fontAttributes];
            }
                break;
            case 3: {
                float price = (priceRange.low + _vm.prevClose)/2.0;
                float rate = _vm.prevClose != 0? (_vm.prevClose - price)/_vm.prevClose * 100.0 : 0.0;
                point.y -= 12;
                [fontAttributes setObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName];
                label = [NSString stringWithFormat:@"%.2f", price];
                [label drawAtPoint:point withAttributes:fontAttributes];
                
                label = [NSString stringWithFormat:@"%.2f%%", rate];
                point.x = CGRectGetMaxX(lineFrame) - 28;
                [label drawAtPoint:point withAttributes:fontAttributes];
            }
                break;
            case 4: {
                float price = priceRange.low;
                float rate = _vm.prevClose != 0? (_vm.prevClose - price)/_vm.prevClose * 100.0 : 0.0;
                point.y -= 12;
                [fontAttributes setObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName];
                label = [NSString stringWithFormat:@"%.2f", price];
                [label drawAtPoint:point withAttributes:fontAttributes];
                
                label = [NSString stringWithFormat:@"%.2f%%", rate];
                point.x = CGRectGetMaxX(lineFrame) - 28;
                [label drawAtPoint:point withAttributes:fontAttributes];
            }
                break;
            default:
                break;
        }
    }
}

// 绘制分时、均线、成交量
- (void)drawLineAndVolume {
    if (_vm.initialized && _vm.prevClose > 0) {
        int count = (int)_vm.dates.count;
        for (int i = 0; i < count; i++) {
            int date = [_vm.dates[i] intValue];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"date = %d", date]];
            NSArray *lines = [NSMutableArray arrayWithArray:[_vm.lines filteredArrayUsingPredicate:predicate]];
            // 按日期绘制分时线
            CGRect drawLineFrame = CGRectMake(CGRectGetMinX(lineFrame) + i * CGRectGetWidth(lineFrame) / count
                                              , CGRectGetMinY(lineFrame)
                                              , CGRectGetWidth(lineFrame) / count
                                              , CGRectGetHeight(lineFrame));
            [self drawDayLineInFrame:drawLineFrame withLines:lines];
            // 按日期绘制成交量
            CGRect drawVolumeFrame = CGRectMake(CGRectGetMinX(volumeFrame) + i * CGRectGetWidth(volumeFrame) / count
                                                , CGRectGetMinY(volumeFrame)
                                                , CGRectGetWidth(volumeFrame) / count
                                                , CGRectGetHeight(volumeFrame));
            [self drawDayVolumeInFrame:drawVolumeFrame withLines:lines];
        }
    }
}

// 绘制日分时线
- (void)drawDayLineInFrame:(CGRect)frame withLines:(NSArray *)lines {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineDash (context, 0, 0, 0);
    CGContextSetLineWidth(context, 1);
    
    NSMutableArray *temp1 = [NSMutableArray array];     // 存放分时线点
    NSMutableArray *temp2 = [NSMutableArray array];     // 存放均线点
    BDTrendLine *prevLine = nil;
    CGPoint point;
    for (BDTrendLine *line in lines) {
        int sn = [_vm getSerialNumberWithTime:line.time];
        if (prevLine == nil) {
            if (sn != 0) {
                point = [_vm getPointInFrame:frame WithSerialNumber:0 andPrice:line.price];
                [temp1 addObject:NSStringFromCGPoint(point)];
                point = [_vm getPointInFrame:frame WithSerialNumber:0 andPrice:line.amount / line.volume];
                [temp2 addObject:NSStringFromCGPoint(point)];
            }
        }
        else {
            if (sn > 0) {
                int prevTime = [_vm getTimeWithSerialNumber:sn-1];
                if (prevTime > prevLine.time) {
                    point = [_vm getPointInFrame:frame WithSerialNumber:sn-1 andPrice:prevLine.price];
                    [temp1 addObject:NSStringFromCGPoint(point)];
                    point = [_vm getPointInFrame:frame WithSerialNumber:sn-1 andPrice:prevLine.amount / prevLine.volume];
                    [temp2 addObject:NSStringFromCGPoint(point)];
                }
            }
        }
        point = [_vm getPointInFrame:frame WithSerialNumber:sn andPrice:line.price];
        [temp1 addObject:NSStringFromCGPoint(point)];
        point = [_vm getPointInFrame:frame WithSerialNumber:sn andPrice:line.amount / line.volume];
        [temp2 addObject:NSStringFromCGPoint(point)];
        prevLine = line;
    }
    
    /* 绘制分时线 */
    CGPoint pricePoints[temp1.count];
    for (int i = 0; i < temp1.count; i++) {
        pricePoints[i] = CGPointFromString(temp1[i]);
    }
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextAddLines(context, pricePoints, temp1.count);
    CGContextDrawPath(context, kCGPathStroke);
    
    /* 绘制均线 */
    CGPoint avgPoints[temp2.count];
    for (int i = 0; i < temp2.count; i++) {
        avgPoints[i] = CGPointFromString(temp2[i]);
    }
    CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
    CGContextAddLines(context, avgPoints, temp2.count);
    CGContextDrawPath(context, kCGPathStroke);
}

// 绘制日成交量
- (void)drawDayVolumeInFrame:(CGRect)frame withLines:(NSArray *)lines {
    float gapWidth = CGRectGetWidth(frame) / (floor(240.0 / _vm.interval) + 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineDash (context, 0, 0, 0);
    CGContextSetStrokeColorWithColor(context, [RGB(220, 108, 32, 1) CGColor]);
    CGContextSetLineWidth(context, gapWidth);
    
    unsigned int maxVolume = _vm.maxVolume;
    BDTrendLine *prevLine = nil;
    for (BDTrendLine *line in lines) {
        int sn = [_vm getSerialNumberWithTime:line.time];
        if (prevLine != nil) {
            unsigned long changeVolume = line.volume - prevLine.volume;
            CGFloat xOffset = CGRectGetMinX(frame) + sn * gapWidth;
            CGFloat yOffset = CGRectGetMinY(frame) + (1 - changeVolume * 1.0 / maxVolume) * CGRectGetHeight(frame);
            CGContextMoveToPoint(context, xOffset, yOffset);
            CGContextAddLineToPoint(context, xOffset, CGRectGetMaxY(frame));
        }
        prevLine = line;
    }
    CGContextDrawPath(context, kCGPathStroke);
}


#pragma mark

- (void)loadTrendLineDataWithNumberOfDays:(int)days {
    _days = days;
    [_vm loadTrendLineForDays:days andInterval:1];
}


#pragma mark - Dealloc

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"priceRange"];
    [_vm removeObserver:self forKeyPath:@"maxVolume"];
}

@end
