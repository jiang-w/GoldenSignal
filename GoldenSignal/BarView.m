//
//  BarView.m
//  GoldenSignal
//
//  Created by Frank on 15/7/13.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BarView.h"

@interface BarView()

@property(nonatomic, strong) CAShapeLayer *barLayer;

@end

@implementation BarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    _barLayer = [CAShapeLayer layer];
    _barLayer.backgroundColor = nil;
    _barLayer.lineWidth = CGRectGetWidth(self.frame);
    [self.layer addSublayer:_barLayer];
    
    if (self.grade != 0) {
        if (self.barColor) {
            _barLayer.strokeColor = [self.barColor CGColor];
        }
        else {
            _barLayer.strokeColor = [[UIColor redColor] CGColor];
        }
        
        UIBezierPath *progressline = [UIBezierPath bezierPath];
        if (self.grade > 0) {
            [progressline moveToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetMaxY(rect))];
            [progressline addLineToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetMaxY(rect) - self.grade * CGRectGetHeight(rect))];
        }
        else {
            [progressline moveToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetMinY(rect))];
            [progressline addLineToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetMinY(rect) - self.grade * CGRectGetHeight(rect))];
        }
        _barLayer.path = progressline.CGPath;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        pathAnimation.autoreverses = NO;
        [_barLayer addAnimation:pathAnimation forKey:nil];
    }
}

@end
