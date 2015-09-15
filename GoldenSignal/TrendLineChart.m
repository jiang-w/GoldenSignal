//
//  TrendLineChart.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "TrendLineChart.h"
#import "TrendLineViewModel.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

@interface TrendLineChart()

@property(nonatomic, strong) NSMutableArray* layers;
@property(nonatomic, strong) UILabel *highLabel, *highRateLabel;
@property(nonatomic, strong) UILabel *lowLabel, *lowRateLabel;
@property(nonatomic, strong) UILabel *middleLabel, *middleRateLabel;
@property(nonatomic) CGRect lineChartFrame;
@property(nonatomic) CGRect volumeChartFrame;

@end

@implementation TrendLineChart
{
    TrendLineViewModel *_vm;
    BDSecuCode *_secu;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _layers = [NSMutableArray array];
        [self setDefaultParameters];
        [self addTextLabel];
        _vm = [[TrendLineViewModel alloc] init];
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
        [_vm addObserver:self forKeyPath:@"prevClose" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)setDefaultParameters {
    self.margin = CGMarginMake(2, 2, 2, 2);
    self.space = 10;
    
    _lineColor = [UIColor orangeColor];
    _avgLineColor = [UIColor yellowColor];
    _fillColor = [_lineColor colorWithAlphaComponent:0.15];
    _lineWidth = 1;
    
    _boundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _boundWidth = 0.5;
    
    _innerGridColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _innerGridWidth = 0.5;
    _drawInnerGrid = YES;
    
    _days = 1;
    _interval = 1;
    
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - property

- (CGRect)lineChartFrame {
    CGPoint origin = CGPointMake(self.margin.left, self.margin.top);
    CGFloat width = CGRectGetWidth(self.frame) - self.margin.left - self.margin.right;
    CGFloat height = (CGRectGetHeight(self.frame) - self.margin.top - self.margin.bottom - _space) / 3.0 * 2;
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    return rect;
}

- (CGRect)volumeChartFrame {
    CGRect lineChartRect = self.lineChartFrame;
    CGPoint origin = CGPointMake(CGRectGetMinX(lineChartRect), CGRectGetMaxY(lineChartRect) + _space);
    CGFloat width = CGRectGetWidth(lineChartRect);
    CGFloat height = CGRectGetHeight(self.frame) - self.margin.bottom - origin.y;
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
            [_vm loadDataWithSecuCode:code forDays:_days andInterval:_interval];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            if (_vm.lines.count > 0 && _vm.prevClose > 0) {
//                NSLog(@"%@ 绘制走势图 (lines:%lu prevClose:%.2f)", _secu.bdCode, (unsigned long)_vm.lines.count, _vm.prevClose);
                [self clearLayers];
                [self strokeLineChart];
                [self strokeVolumeChart];
                [MBProgressHUD hideHUDForView:self animated:YES];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TrendLineChart 绘制走势图异常: %@", exception.reason);
        }
    });
}


#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
    [self layoutTextLabel];
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
        CGContextSetLineDash(ctx, 0, (CGFloat[]){4, 4}, 2);
        
        NSInteger horizontalGridStep = _days > 1 ? _days : 4;
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

- (void)addTextLabel {
    self.highLabel = [[UILabel alloc] init];
    self.highLabel.textAlignment = NSTextAlignmentLeft;
    self.highLabel.font = [UIFont systemFontOfSize:9];
    self.highLabel.textColor = [UIColor redColor];
    [self addSubview:self.highLabel];

    self.highRateLabel = [[UILabel alloc] init];
    self.highRateLabel.textAlignment = NSTextAlignmentRight;
    self.highRateLabel.font = [UIFont systemFontOfSize:9];
    self.highRateLabel.textColor = [UIColor redColor];
    [self addSubview:self.highRateLabel];
    
    self.lowLabel = [[UILabel alloc] init];
    self.lowLabel.textAlignment = NSTextAlignmentLeft;
    self.lowLabel.font = [UIFont systemFontOfSize:9];
    self.lowLabel.textColor = [UIColor greenColor];
    [self addSubview:self.lowLabel];
    
    self.lowRateLabel = [[UILabel alloc] init];
    self.lowRateLabel.textAlignment = NSTextAlignmentRight;
    self.lowRateLabel.font = [UIFont systemFontOfSize:9];
    self.lowRateLabel.textColor = [UIColor greenColor];
    [self addSubview:self.lowRateLabel];
    
    self.middleLabel = [[UILabel alloc] init];
    self.middleLabel.textAlignment = NSTextAlignmentLeft;
    self.middleLabel.font = [UIFont systemFontOfSize:9];
    self.middleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.middleLabel];
    
    self.middleRateLabel = [[UILabel alloc] init];
    self.middleRateLabel.textAlignment = NSTextAlignmentRight;
    self.middleRateLabel.font = [UIFont systemFontOfSize:9];
    self.middleRateLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.middleRateLabel];
}

- (void)layoutTextLabel {
    CGRect frame = self.lineChartFrame;
    [self.highLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(CGRectGetMinY(frame) + 1);
        make.left.equalTo(self).with.offset(CGRectGetMinX(frame) + 2);
    }];
    [self.highRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(CGRectGetMinY(frame) + 1);
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMaxX(frame) - 2);
    }];
    [self.lowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top).with.offset(CGRectGetMaxY(frame) - 1);
        make.left.equalTo(self).with.offset(CGRectGetMinX(frame) + 2);
    }];
    [self.lowRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top).with.offset(CGRectGetMaxY(frame) - 1);
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMaxX(frame) - 2);
    }];
    [self.middleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_top).with.offset(CGRectGetHeight(frame) / 2);
        make.left.equalTo(self).with.offset(CGRectGetMinX(frame) + 2);
    }];
    [self.middleRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_top).with.offset(CGRectGetHeight(frame) / 2);
        make.right.equalTo(self.mas_left).with.offset(CGRectGetMaxX(frame) - 2);
    }];
}

- (void)strokeLineChart {
//    Stopwatch *watch = [Stopwatch startNew];
    NSArray *dates = _vm.tradingDays;
    CGRect chartFrame = self.lineChartFrame;
    CGFloat xOffset = CGRectGetWidth(chartFrame) / dates.count;
    
    for (int i = 0; i < dates.count; i++) {
        CGRect frame = CGRectMake(chartFrame.origin.x + xOffset * i, chartFrame.origin.y, xOffset, chartFrame.size.height);
        // 绘制日分时线
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = frame;
        pathLayer.path = [self getPricePathInFrame:pathLayer.bounds forTradingDay:dates[i] andIsClosed:NO];
        pathLayer.strokeColor = [_lineColor CGColor];
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = _lineWidth;
        pathLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:pathLayer];
        [self.layers addObject:pathLayer];
        // 填充
        if(_fillColor && _fillColor != [UIColor clearColor]) {
            CAShapeLayer* fillLayer = [CAShapeLayer layer];
            fillLayer.frame = frame;
            fillLayer.path = [self getPricePathInFrame:fillLayer.bounds forTradingDay:dates[i] andIsClosed:YES];
            fillLayer.strokeColor = nil;
            fillLayer.fillColor = _fillColor.CGColor;
            fillLayer.lineWidth = 0;
            fillLayer.lineJoin = kCALineJoinRound;
            [self.layer addSublayer:fillLayer];
            [self.layers addObject:fillLayer];
        }
        if (_secu.typ == stock) {
            // 绘制个股均线
            CAShapeLayer *avgLineLayer = [CAShapeLayer layer];
            avgLineLayer.frame = frame;
            avgLineLayer.path = [self getAvgPricePathInFrame:avgLineLayer.bounds forTradingDay:dates[i]];
            avgLineLayer.strokeColor = [_avgLineColor CGColor];
            avgLineLayer.fillColor = nil;
            avgLineLayer.lineWidth = _lineWidth;
            avgLineLayer.lineJoin = kCALineJoinRound;
            [self.layer addSublayer:avgLineLayer];
            [self.layers addObject:avgLineLayer];
        }
    }
    
    PriceRange range = _vm.priceRange;
    self.highLabel.text = [NSString stringWithFormat:@"%.2f", range.high];
    self.highRateLabel.text = [NSString stringWithFormat:@"%.2f%%", (range.high - _vm.prevClose) / _vm.prevClose * 100];
    self.lowLabel.text = [NSString stringWithFormat:@"%.2f", range.low];
    self.lowRateLabel.text = [NSString stringWithFormat:@"%.2f%%", (range.low - _vm.prevClose) / _vm.prevClose * 100];
    self.middleLabel.text = [NSString stringWithFormat:@"%.2f", _vm.prevClose];
    self.middleRateLabel.text = @"00.0%";
    
//    [watch stop];
//    NSLog(@"绘制分时线 Timeout:%.3fs", watch.elapsed);
}

- (void)strokeVolumeChart {
//    Stopwatch *watch = [Stopwatch startNew];
    NSArray *dates = _vm.tradingDays;
    CGRect chartFrame = self.volumeChartFrame;
    CGFloat xOffset = CGRectGetWidth(chartFrame) / dates.count;
    
    for (int i = 0; i < dates.count; i++) {
        CGRect frame = CGRectMake(chartFrame.origin.x + xOffset * i, chartFrame.origin.y, xOffset, chartFrame.size.height);
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = frame;
        pathLayer.path = [self getVolumePathInFrame:pathLayer.bounds forTradingDay:dates[i]];
        pathLayer.strokeColor = [RGB(217, 166, 58) CGColor];
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = 1;
        pathLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:pathLayer];
        [self.layers addObject:pathLayer];
    }
//    [watch stop];
//    NSLog(@"绘制交易量 Timeout:%.3fs", watch.elapsed);
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

- (CGPathRef)getAvgPricePathInFrame:(CGRect)frame forTradingDay:(NSString *)date {
    NSArray *points = [_vm getAvgPricePointInFrame:frame forTradingDay:date];
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
    }
    return path.CGPath;
}

- (CGMutablePathRef)getVolumePathInFrame:(CGRect)frame forTradingDay:(NSString *)date {
    NSArray *points = [_vm getVolumePointInFrame:frame forTradingDay:date];
    CGMutablePathRef path =CGPathCreateMutable();
    for (int i = 0; i < points.count; i++) {
        CGPoint point = CGPointFromString(points[i]);
        CGPathMoveToPoint(path, NULL, point.x, CGRectGetMaxY(frame));
        CGPathAddLineToPoint(path,NULL, point.x, point.y);
    }
    return path;
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
    [_vm removeObserver:self forKeyPath:@"prevClose"];
//    NSLog(@"TrendLineChart dealloc (%@)", _secu.bdCode);
}

@end
