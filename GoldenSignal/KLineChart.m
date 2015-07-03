//
//  KLineChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "KLineChart.h"
#import "KLineChartViewModel.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

@interface KLineChart()

@end

@implementation KLineChart
{
    KLineChartViewModel *_vm;
    BDSecuCode *_secu;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultParameters];
        [self addTextLabel];
        _vm = [[KLineChartViewModel alloc] init];
        [_vm addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)setDefaultParameters {
    self.margin = 0.0f;
    self.space = 4.0f;
    
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
            [_vm loadDataWithSecuCode:code forType:_type andNumber:_number];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            if (_vm.lines.count > 0) {
                [self strokeCandleChart];
                [self strokeVolumeChart];
                [MBProgressHUD hideHUDForView:self animated:YES];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"KLineChart 绘制K线异常: %@", exception.reason);
        }
    });
}


#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    [self drawGrid];
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
        
        NSInteger horizontalGridStep = 3;
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
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x + CGRectGetWidth(lineChartRect), point.y);
            CGContextStrokePath(ctx);
        }
    }
}

- (void)addTextLabel {
    
}

- (void)strokeCandleChart {
    
}

- (void)strokeVolumeChart {
    
}

@end
