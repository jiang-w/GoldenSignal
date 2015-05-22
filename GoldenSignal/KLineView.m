//
//  KLineView.m
//  CBNAPP
//
//  Created by Frank on 14/12/3.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "KLineView.h"
#import "KLineViewModel.h"
#import "MBProgressHUD/MBProgressHUD.h"

#define ExtraKLine 20

@implementation KLineView
{
    KLineViewModel *_vm;
    int _number;
    NSArray *fetchLines;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        lineFrame = CGRectMake(40, 15, self.frame.size.width - 44, (self.frame.size.height - 15*3)/6.0*4);
        volumeFrame = CGRectMake(40, lineFrame.size.height+15*2, self.frame.size.width - 44, (self.frame.size.height - 15*3)/6.0*2);
        [self addXYLineAndGesture];
        
        if (code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.opacity = 0;
            
            _code = [code copy];
            _vm = [[KLineViewModel alloc] initWithCode:code];
            [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_vm.initialized) {
            if (_vm.lines.count > _number) {
                NSRange range = NSMakeRange(_vm.lines.count - _number, _number);
                fetchLines = [_vm.lines subarrayWithRange:range];
            }
            else {
                fetchLines = _vm.lines;
            }
        }
        
        [self setNeedsDisplay];
        [MBProgressHUD hideHUDForView:self animated:YES];
    });
}


#pragma mark - Draw View

- (void)drawRect:(CGRect)rect {
    @try {
        [self drawGrid];
        [self drawKLine];
    }
    @catch (NSException *exception) {
        NSLog(@"KLineView 绘制K线异常");
    }
}

// 绘制网格
- (void)drawGrid {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置画笔颜色和宽度
    CGContextSetStrokeColorWithColor(context, [RGB(80.0, 80.0, 80.0, 1.0) CGColor]);
    CGContextSetLineWidth(context, 1);
    
    int kLineBlockCount = 4;
    int volumeBlockCount = 2;
    
    // 绘制边框
    CGContextAddRect(context, lineFrame);
    CGContextDrawPath(context, kCGPathStroke);
    CGFloat interval = lineFrame.size.height / kLineBlockCount;
    for (int i = 1; i < kLineBlockCount; i++) {
        CGFloat yOffset = lineFrame.origin.y + interval * i;
        CGPoint startPoint = CGPointMake(lineFrame.origin.x, yOffset);
        CGPoint endPoint = CGPointMake(lineFrame.origin.x + lineFrame.size.width, yOffset);
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextDrawPath(context, kCGPathStroke);
    }

    CGContextAddRect(context, volumeFrame);
    CGContextDrawPath(context, kCGPathStroke);
    interval = volumeFrame.size.height / volumeBlockCount;
    for (int i = 1; i < volumeBlockCount; i++) {
        CGFloat yOffset = volumeFrame.origin.y + interval * i;
        CGPoint startPoint = CGPointMake(volumeFrame.origin.x, yOffset);
        CGPoint endPoint = CGPointMake(volumeFrame.origin.x + volumeFrame.size.width, yOffset);
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    // 绘制参考价格
    PriceRange priceRange = _vm.priceRange;
    interval = lineFrame.size.height / kLineBlockCount;
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    [fontAttributes setObject:[UIFont systemFontOfSize:9] forKey:NSFontAttributeName];
    [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    CGPoint originPoint = lineFrame.origin;
    for (int i = 0; i <= kLineBlockCount; i++) {
        CGPoint point = CGPointMake(originPoint.x, originPoint.y + interval * i);
        float price = priceRange.high - (priceRange.high - priceRange.low) / kLineBlockCount * i;
        NSString *label = [NSString stringWithFormat:@"%.2f", price];
        CGFloat textWidth = [label boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.width;
        CGFloat textheight = [label boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.height;
        point.x -= textWidth + 4;
        point.y -= textheight / 2;
        [label drawAtPoint:point withAttributes:fontAttributes];
    }
    
    unsigned int maxVolume = _vm.maxVolume;
    NSString *label = [NSString stringWithFormat:@"%.0f万", maxVolume/1000000.0];
    CGFloat textWidth = [label boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.width;
    CGPoint point = volumeFrame.origin;
    point.x -= textWidth + 2;
    [label drawAtPoint:point withAttributes:fontAttributes];
}


- (void)drawKLine {
    PriceRange priceRange = _vm.priceRange;
    if (priceRange.high - priceRange.low == 0) {
        return;
    }
    
    unsigned int maxVolume = _vm.maxVolume;
    CGContextRef context = UIGraphicsGetCurrentContext();
    float lineWidth = lineFrame.size.width / _number;
    for (int i = 0; i < fetchLines.count; i++) {
        BDKLine *kLine = fetchLines[i];
        float xOffset = CGRectGetMinX(lineFrame) + lineWidth * (i + 1) - lineWidth / 2;
        float highYOffset = (priceRange.high - kLine.high) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        float lowYOffset = (priceRange.high - kLine.low) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        float openYOffset = (priceRange.high - kLine.open) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        float closeYOffset = (priceRange.high - kLine.close) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
        if (kLine.open == kLine.close) {
            openYOffset += 0.5;
            closeYOffset -= 0.5;
        }
        float volumeYOffset = (maxVolume - kLine.volume) * 1.0 / maxVolume * CGRectGetHeight(volumeFrame) + CGRectGetMinY(volumeFrame);
        
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
        
        // 绘制交易量
        CGContextMoveToPoint(context, xOffset, volumeYOffset);
        CGContextAddLineToPoint(context, xOffset, CGRectGetMaxY(volumeFrame));
        CGContextStrokePath(context);
        
    }
    
    if (fetchLines.count > 0) {
        // 绘制开始日期
        NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
        [fontAttributes setObject:[UIFont systemFontOfSize:9] forKey:NSFontAttributeName];
        [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSString *startDate = [NSString stringWithFormat:@"%d", [(BDTrendLine *)[fetchLines firstObject] date]];
        CGPoint startPoint = CGPointMake(CGRectGetMinX(volumeFrame), CGRectGetMaxY(volumeFrame) + 1);
        [startDate drawAtPoint:startPoint withAttributes:fontAttributes];
        
        // 绘制结束日期
        fontAttributes = [NSMutableDictionary dictionary];
        [fontAttributes setObject:[UIFont systemFontOfSize:9] forKey:NSFontAttributeName];
        [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSString *endDate = [NSString stringWithFormat:@"%d", [(BDTrendLine *)[fetchLines lastObject] date]];
        CGFloat textWidth = [endDate boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.width;
        CGPoint endPoint = CGPointMake(CGRectGetMaxX(volumeFrame) - textWidth, CGRectGetMaxY(volumeFrame) + 1);
        [endDate drawAtPoint:endPoint withAttributes:fontAttributes];
    }
    
    // 绘制MA5
    CGPoint ma5StartPoint = CGPointZero;
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    for (int i = 0; i < fetchLines.count; i++) {
        BDKLine *kLine = fetchLines[i];
        float xOffset = CGRectGetMinX(lineFrame) + lineWidth * (i + 1) - lineWidth / 2;
        float ma5Price = [_vm calcAvgPriceForDate:kLine.date andMA:5];  //MA5
        if (ma5Price != 0) {
            float ma5YOffset = (priceRange.high - ma5Price) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
            CGPoint ma5Point = CGPointMake(xOffset, ma5YOffset);
            if (CGPointEqualToPoint(ma5StartPoint, CGPointZero)) {
                ma5StartPoint = ma5Point;
            }
            else {
                CGContextMoveToPoint(context, ma5StartPoint.x, ma5StartPoint.y);
                CGContextAddLineToPoint(context, ma5Point.x, ma5Point.y);
                CGContextStrokePath(context);
                ma5StartPoint = ma5Point;
            }
        }
    }
    
    // 绘制MA10
    CGPoint ma10StartPoint = CGPointZero;
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
    for (int i = 0; i < fetchLines.count; i++) {
        BDKLine *kLine = fetchLines[i];
        float xOffset = CGRectGetMinX(lineFrame) + lineWidth * (i + 1) - lineWidth / 2;
        float ma10Price = [_vm calcAvgPriceForDate:kLine.date andMA:10];    //MA10
        if (ma10Price != 0) {
            float ma10YOffset = (priceRange.high - ma10Price) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
            CGPoint ma10Point = CGPointMake(xOffset, ma10YOffset);
            if (CGPointEqualToPoint(ma10StartPoint, CGPointZero)) {
                ma10StartPoint = ma10Point;
            }
            else {
                CGContextMoveToPoint(context, ma10StartPoint.x, ma10StartPoint.y);
                CGContextAddLineToPoint(context, ma10Point.x, ma10Point.y);
                CGContextStrokePath(context);
                ma10StartPoint = ma10Point;
            }
        }
    }
    
    // 绘制MA20
    CGPoint ma20StartPoint = CGPointZero;
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [RGB(46, 169, 223, 1) CGColor]);
    for (int i = 0; i < fetchLines.count; i++) {
        BDKLine *kLine = fetchLines[i];
        float xOffset = CGRectGetMinX(lineFrame) + lineWidth * (i + 1) - lineWidth / 2;
        float ma20Price = [_vm calcAvgPriceForDate:kLine.date andMA:20];    //MA20
        if (ma20Price != 0) {
            float ma20YOffset = (priceRange.high - ma20Price) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame) + CGRectGetMinY(lineFrame);
            CGPoint ma20Point = CGPointMake(xOffset, ma20YOffset);
            if (CGPointEqualToPoint(ma20StartPoint, CGPointZero)) {
                ma20StartPoint = ma20Point;
            }
            else {
                CGContextMoveToPoint(context, ma20StartPoint.x, ma20StartPoint.y);
                CGContextAddLineToPoint(context, ma20Point.x, ma20Point.y);
                CGContextStrokePath(context);
                ma20StartPoint = ma20Point;
            }
        }
    }
}


#pragma mark - Gesture

- (void)addXYLineAndGesture {
    xLine = [[UILabel alloc] initWithFrame:
             CGRectMake(CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame), CGRectGetWidth(lineFrame), 1)];
    xLine.backgroundColor = [UIColor whiteColor];
    xLine.hidden = YES;
    [self addSubview:xLine];
    
    yLine = [[UILabel alloc] initWithFrame:
             CGRectMake(CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame), 1, CGRectGetMaxY(volumeFrame) - CGRectGetMinY(lineFrame))];
    yLine.backgroundColor = [UIColor whiteColor];
    yLine.hidden = YES;
    [self addSubview:yLine];
    
    xLabel = [[UILabel alloc] initWithFrame:
              CGRectMake(CGRectGetMinX(lineFrame) - 29, CGRectGetMinY(lineFrame), 28, 12)];
    xLabel.font = [UIFont systemFontOfSize:9];
    xLabel.textAlignment = NSTextAlignmentCenter;
    xLabel.backgroundColor = [UIColor grayColor];
    xLabel.hidden = YES;
    [self addSubview:xLabel];
    
    yLabel = [[UILabel alloc] initWithFrame:
              CGRectMake(CGRectGetMinX(lineFrame), CGRectGetMaxY(volumeFrame) + 1, 32, 12)];
    yLabel.font = [UIFont systemFontOfSize:8];
    yLabel.textAlignment = NSTextAlignmentCenter;
    yLabel.backgroundColor = [UIColor grayColor];
    yLabel.hidden = YES;
    [self addSubview:yLabel];
    
    // 添加长按手势识别器
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setCrossLineWithGesture:)];
    longPressGr.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPressGr];
}

- (void)setCrossLineWithGesture:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        xLine.hidden = YES;
        yLine.hidden = YES;
        xLabel.hidden = YES;
        yLabel.hidden = YES;
    }
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchXOffset = touchPoint.x - CGRectGetMinX(lineFrame);
    CGRect recognitionRegion = CGRectMake(CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame)
                                          , CGRectGetWidth(lineFrame), CGRectGetMaxY(volumeFrame) - CGRectGetMinY(lineFrame));
    if (CGRectContainsPoint(recognitionRegion, touchPoint)) {
        float lineWidth = lineFrame.size.width / _number;
        int index = floor(touchXOffset / lineWidth);
        if (fetchLines.count > 0) {
            if (index >= fetchLines.count) {
                index = (int)fetchLines.count - 1;
            }
            if (index < 0) {
                index = 0;
            }

            BDKLine *kLine = fetchLines[index];
            xLabel.text = [NSString stringWithFormat:@"%.2f", kLine.close];
            yLabel.text = [NSString stringWithFormat:@"%d", kLine.date % 1000000];
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                xLine.hidden = NO;
                yLine.hidden = NO;
                xLabel.hidden = NO;
                yLabel.hidden = NO;
            }

            PriceRange priceRange = _vm.priceRange;
            CGPoint crossPoint = CGPointMake(CGRectGetMinX(lineFrame) + lineWidth * (index + 1) - lineWidth / 2,
                                             CGRectGetMinY(lineFrame) + (priceRange.high - kLine.close) / (priceRange.high - priceRange.low) * CGRectGetHeight(lineFrame));
            CGRect xLineFrame = xLine.frame;
            xLineFrame.origin.y = crossPoint.y - 0.5;
            [xLine setFrame:xLineFrame];
            
            CGRect yLineFrame = yLine.frame;
            yLineFrame.origin.x = crossPoint.x - 0.5;
            [yLine setFrame:yLineFrame];
            
            CGRect xLabelFrame = xLabel.frame;
            xLabelFrame.origin.y = crossPoint.y - xLabelFrame.size.height / 2;
            [xLabel setFrame:xLabelFrame];
            
            CGRect yLabelFrame = yLabel.frame;
            if (CGRectGetMaxX(lineFrame) - crossPoint.x < yLabelFrame.size.width / 2) {
                yLabelFrame.origin.x = CGRectGetMaxX(lineFrame) - yLabel.frame.size.width;
            }
            else if (crossPoint.x - CGRectGetMinX(lineFrame) < yLabelFrame.size.width / 2) {
                yLabelFrame.origin.x = CGRectGetMinX(lineFrame);
            }
            else {
                yLabelFrame.origin.x = crossPoint.x - yLabelFrame.size.width / 2;
            }
            [yLabel setFrame:yLabelFrame];
        }
    }
}

#pragma mark

- (void)loadKLineDataWithType:(KLineType)type andNumber:(int)number {
    _number = number;
    [_vm loadKLineWithType:type andNumber:number + ExtraKLine];
}

#pragma mark - Dealloc

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"lines"];
}

@end
