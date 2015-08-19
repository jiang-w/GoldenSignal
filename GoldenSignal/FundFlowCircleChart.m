//
//  FundFlowCircleChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/10.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowCircleChart.h"
#import <Masonry.h>

@interface FundFlowCircleChart()

@property(nonatomic, strong) NSMutableArray* layers;
@property(nonatomic, strong) UILabel *title;
@property(nonatomic, strong) UIView *circle;

@end

@implementation FundFlowCircleChart
{
    double _fundFlowIn;
    double _fundFlowOut;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _layers = [NSMutableArray array];
        [self setSubView];
        
        _fundFlowIn = 500;
        _fundFlowOut = 800;
    }
    return self;
}

- (void)setSubView {
    self.title = [[UILabel alloc] init];
    self.title.text = @"今日实时资金博弈";
    self.title.font = [UIFont boldSystemFontOfSize:12];
    self.title.textColor = [UIColor whiteColor];
    [self addSubview:self.title];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
    }];
    
    self.circle = [[UIView alloc] init];
    [self addSubview:self.circle];
    [self.circle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.height.equalTo(self.circle.mas_width);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-10);
    }];
}

- (void)drawRect:(CGRect)rect {
    [self strokeCircle];
}

- (void)strokeCircle {
    CGFloat radius = (self.circle.frame.size.height - 20) / 2;
    CGPoint center = self.circle.center;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = path.CGPath;
    backgroundLayer.strokeColor = [RGB(59, 59, 59, 1) CGColor];
    backgroundLayer.fillColor = nil;
    backgroundLayer.lineWidth = 20;
    [self.layer addSublayer:backgroundLayer];
    [self.layers addObject:backgroundLayer];
    
    CGFloat startAngle = 0;
    CGFloat endAngle = 2 * M_PI * _fundFlowOut / (_fundFlowOut + _fundFlowIn);
    
    path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *flowOutLayer = [CAShapeLayer layer];
    flowOutLayer.path = path.CGPath;
    flowOutLayer.strokeColor = [[UIColor greenColor] CGColor];
    flowOutLayer.fillColor = nil;
    flowOutLayer.lineWidth = 12;
    [self.layer addSublayer:flowOutLayer];
    [self.layers addObject:flowOutLayer];
    
    path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:endAngle endAngle:startAngle clockwise:YES];
    CAShapeLayer *flowInLayer = [CAShapeLayer layer];
    flowInLayer.path = path.CGPath;
    flowInLayer.strokeColor = [[UIColor redColor] CGColor];
    flowInLayer.fillColor = nil;
    flowInLayer.lineWidth = 12;
    [self.layer addSublayer:flowInLayer];
    [self.layers addObject:flowInLayer];
}

@end
