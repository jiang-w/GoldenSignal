//
//  FundFlowCircleChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/10.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowCircleChart.h"

@implementation FundFlowCircleChart

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect {
    [self addBackgroundLayer];
}

- (void)addBackgroundLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.center radius:60 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = path.CGPath;
    backgroundLayer.strokeColor = [RGB(59, 59, 59, 1) CGColor];
    backgroundLayer.fillColor = nil;
    backgroundLayer.lineWidth = 20;
    [self.layer addSublayer:backgroundLayer];
    
    CGFloat startAngle = - M_PI / 180 * 60;
    CGFloat endAngle = - M_PI;
    path = [UIBezierPath bezierPathWithArcCenter:self.center radius:60 startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *flowOutLayer = [CAShapeLayer layer];
    flowOutLayer.path = path.CGPath;
    flowOutLayer.strokeColor = [[UIColor greenColor] CGColor];
    flowOutLayer.fillColor = nil;
    flowOutLayer.lineWidth = 12;
    [self.layer addSublayer:flowOutLayer];
    
    path = [UIBezierPath bezierPathWithArcCenter:self.center radius:60 startAngle:endAngle endAngle:startAngle clockwise:YES];
    CAShapeLayer *flowInLayer = [CAShapeLayer layer];
    flowInLayer.path = path.CGPath;
    flowInLayer.strokeColor = [[UIColor redColor] CGColor];
    flowInLayer.fillColor = nil;
    flowInLayer.lineWidth = 12;
    [self.layer addSublayer:flowInLayer];
    
}

@end
