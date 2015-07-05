//
//  KLineChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "KLineChart.h"
#import "KLineViewModel.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

@interface KLineChart()

@property(nonatomic, strong) NSMutableArray* layers;
@property(nonatomic, strong) UILabel *highLabel, *lowLabel;
@property(nonatomic, strong) UILabel *volumeLabel;
@property(nonatomic, strong) UILabel *beginDateLabel, *endDateLabel;
@property(nonatomic) CGRect lineChartFrame;
@property(nonatomic) CGRect volumeChartFrame;

@end

@implementation KLineChart
{
    KLineViewModel *_vm;
    BDSecuCode *_secu;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _layers = [NSMutableArray array];
        [self setDefaultParameters];
        [self addTextLabel];
        _vm = [[KLineViewModel alloc] init];
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)setDefaultParameters {
    self.margin = 6.0;
    self.margin_left = 42.0;
    self.margin_top = 10.0;
    self.margin_bottom = 16.0;
    self.space = 10.0;
    
    _boundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _boundWidth = 0.5;
    
    _innerGridColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _innerGridWidth = 0.5;
    _drawInnerGrid = YES;
    
     _type = KLINE_DAY;
    _number = 60;
    
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - property

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
    CGRect lineChartRect = self.lineChartFrame;
    CGPoint origin = CGPointMake(CGRectGetMinX(lineChartRect), CGRectGetMaxY(lineChartRect) + _space);
    CGFloat width = CGRectGetWidth(lineChartRect);
    CGFloat height = CGRectGetHeight(self.frame) - _margin_bottom - origin.y;
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    return rect;
}


#pragma mark - loading data

- (void)loadDataWithSecuCode:(NSString *)code {
    if (code) {
        if (_secu == nil || ![_secu.bdCode isEqualToString:code]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.opacity = 0;
            _secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
            [_vm loadDataWithSecuCode:_secu.bdCode forType:_type andNumber:_number];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
//            NSLog(@"%@ 绘制K线图 (number:%lu)", _secu.bdCode, _number);
            [self setNeedsDisplay];
            [MBProgressHUD hideHUDForView:self animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"KLineChart 绘制K线异常: %@", exception.reason);
        }
    });
}


#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
    if (_vm.lines.count > 0) {
        [self clearLayers];
        [self strokeCandleChart];
        [self strokeAvgLineChart];
    }
}

- (void)drawGrid {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, _boundWidth);
    CGContextSetStrokeColorWithColor(ctx, [_boundColor CGColor]);
    
    // draw bound
    CGRect lineChartRect = self.lineChartFrame;
    CGRect volumeChartRect = self.volumeChartFrame;
    CGContextAddRect(ctx, lineChartRect);
    CGContextStrokePath(ctx);
    CGContextAddRect(ctx, volumeChartRect);
    CGContextStrokePath(ctx);
    
    // draw grid
    if(_drawInnerGrid) {
        CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
        CGContextSetLineWidth(ctx, _innerGridWidth);
        
        int verticalGridStep = 4;
        for(int i = 1; i < verticalGridStep; i++) {
            CGPoint point = CGPointMake(CGRectGetMinX(lineChartRect), i * CGRectGetHeight(lineChartRect) / verticalGridStep + CGRectGetMinY(lineChartRect));
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x + CGRectGetWidth(lineChartRect), point.y);
            CGContextStrokePath(ctx);
        }
    }
}

- (void)addTextLabel {
    CGRect frame = self.lineChartFrame;
    self.highLabel = [[UILabel alloc] init];
    self.highLabel.textAlignment = NSTextAlignmentRight;
    self.highLabel.font = [UIFont systemFontOfSize:9];
    self.highLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.highLabel];
    [self.highLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_top).with.offset(CGRectGetMinY(frame));
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMinX(frame) + -2);
    }];

    self.lowLabel = [[UILabel alloc] init];
    self.lowLabel.textAlignment = NSTextAlignmentRight;
    self.lowLabel.font = [UIFont systemFontOfSize:9];
    self.lowLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.lowLabel];
    [self.lowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_top).with.offset(CGRectGetMaxY(frame));
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMinX(frame) + -2);
    }];

    frame = self.volumeChartFrame;
    self.volumeLabel = [[UILabel alloc] init];
    self.volumeLabel.textAlignment = NSTextAlignmentRight;
    self.volumeLabel.font = [UIFont systemFontOfSize:9];
    self.volumeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.volumeLabel];
    [self.volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(CGRectGetMinY(frame));
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMinX(frame) + -2);
    }];
    
    self.beginDateLabel = [[UILabel alloc] init];
    self.beginDateLabel.textAlignment = NSTextAlignmentRight;
    self.beginDateLabel.font = [UIFont systemFontOfSize:9];
    self.beginDateLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.beginDateLabel];
    [self.beginDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(CGRectGetMaxY(frame) + 2);
        make.left.equalTo(self).with.offset(CGRectGetMinX(frame));
    }];
    
    self.endDateLabel = [[UILabel alloc] init];
    self.endDateLabel.textAlignment = NSTextAlignmentRight;
    self.endDateLabel.font = [UIFont systemFontOfSize:9];
    self.endDateLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.endDateLabel];
    [self.endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(CGRectGetMaxY(frame) + 2);
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMaxX(frame));
    }];
}

- (void)strokeCandleChart {
//    Stopwatch *watch = [Stopwatch startNew];
    PriceRange priceRange = _vm.priceRange;
    unsigned long maxVolume = _vm.maxVolume;
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
        float volumeYOffset = (maxVolume - kLine.volume) * 1.0 / maxVolume * CGRectGetHeight(self.volumeChartFrame) + CGRectGetMinY(self.volumeChartFrame);
        
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
        CGContextAddLineToPoint(context, xOffset, CGRectGetMaxY(self.volumeChartFrame));
        CGContextStrokePath(context);
    }
    
    self.highLabel.text = [NSString stringWithFormat:@"%.2f", priceRange.high];
    self.lowLabel.text = [NSString stringWithFormat:@"%.2f", priceRange.low];
    double volume = maxVolume / 1000000.0;
    self.volumeLabel.text = [NSString stringWithFormat:@"%lu", maxVolume];
    if (volume >= 10000) {
        self.volumeLabel.text = [NSString stringWithFormat:@"%.2f亿", volume / 10000];
    }
    else {
        self.volumeLabel.text = [NSString stringWithFormat:@"%.0f万", volume];
    }
    self.beginDateLabel.text = [NSString stringWithFormat:@"%d", ((BDKLine *)[lines firstObject]).date];
    self.endDateLabel.text = [NSString stringWithFormat:@"%d", ((BDKLine *)[lines lastObject]).date];
    
//    [watch stop];
//    NSLog(@"绘制K线 Timeout:%.3fs", watch.elapsed);
}

- (void)strokeAvgLineChart {
//    Stopwatch *watch = [Stopwatch startNew];
    // 绘制MA5
    CGPathRef ma5LinePath = [self getAvgPricePathInFrame:self.lineChartFrame withMA:5];
    CAShapeLayer *ma5LineLayer = [CAShapeLayer layer];
    ma5LineLayer.frame = self.bounds;
    ma5LineLayer.path = ma5LinePath;
    ma5LineLayer.strokeColor = [[UIColor whiteColor] CGColor];
    ma5LineLayer.fillColor = nil;
    ma5LineLayer.lineWidth = 1;
    ma5LineLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:ma5LineLayer];
    [self.layers addObject:ma5LineLayer];
    
    // 绘制MA10
    CGPathRef ma10LinePath = [self getAvgPricePathInFrame:self.lineChartFrame withMA:10];
    CAShapeLayer *ma10LineLayer = [CAShapeLayer layer];
    ma10LineLayer.frame = self.bounds;
    ma10LineLayer.path = ma10LinePath;
    ma10LineLayer.strokeColor = [[UIColor yellowColor] CGColor];
    ma10LineLayer.fillColor = nil;
    ma10LineLayer.lineWidth = 1;
    ma10LineLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:ma10LineLayer];
    [self.layers addObject:ma10LineLayer];
    
    // 绘制MA20
    CGPathRef ma20LinePath = [self getAvgPricePathInFrame:self.lineChartFrame withMA:20];
    CAShapeLayer *ma20LineLayer = [CAShapeLayer layer];
    ma20LineLayer.frame = self.bounds;
    ma20LineLayer.path = ma20LinePath;
    ma20LineLayer.strokeColor = [RGB(46, 169, 223, 1) CGColor];
    ma20LineLayer.fillColor = nil;
    ma20LineLayer.lineWidth = 1;
    ma20LineLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:ma20LineLayer];
    [self.layers addObject:ma20LineLayer];
    
//    [watch stop];
//    NSLog(@"绘制均线 Timeout:%.3fs", watch.elapsed);
}

- (CGPathRef)getAvgPricePathInFrame:(CGRect)frame withMA:(NSUInteger)value {
    UIBezierPath* path = [UIBezierPath bezierPath];
    PriceRange priceRange = _vm.priceRange;
    double scale = (priceRange.high - priceRange.low) / CGRectGetHeight(frame);
    
    CGPoint beginPoint = CGPointZero;
    NSRange range = _vm.lines.count > _number ? NSMakeRange(_vm.lines.count - _number, _number) : NSMakeRange(0, _vm.lines.count);
    NSArray *lines = [_vm.lines subarrayWithRange:range];
    for (int i = 0; i < lines.count; i++) {
        BDKLine *line = lines[i];
        double price = [_vm calcAvgPriceForDate:line.date andMA:value];
        if (price > 0) {
            CGFloat xOffset = CGRectGetMinX(frame) + (i + 0.5) * CGRectGetWidth(frame) / lines.count;
            CGFloat yOffset = CGRectGetMaxY(frame) - (price - priceRange.low) / scale;
            if (CGPointEqualToPoint(beginPoint, CGPointZero)) {
                beginPoint = CGPointMake(xOffset, yOffset);
                [path moveToPoint:beginPoint];
            }
            else {
                [path addLineToPoint:CGPointMake(xOffset, yOffset)];
            }
        }
    }
    return path.CGPath;
}

- (void)clearLayers {
    for (CALayer *layer in self.layers) {
        [layer removeFromSuperlayer];
    }
    [self.layers removeAllObjects];
}

#pragma mark - Dealloc

- (void)dealloc {
    [_vm removeObserver:self forKeyPath:@"lines"];
    NSLog(@"KLineChart dealloc (%@)", _secu.bdCode);
}

@end
