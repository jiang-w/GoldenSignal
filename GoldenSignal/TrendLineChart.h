//
//  TrendLineChart.h
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendLineChart : UIView

// margin with bound
@property (nonatomic) CGFloat margin;
@property (nonatomic) CGFloat margin_top;
@property (nonatomic) CGFloat margin_left;
@property (nonatomic) CGFloat margin_bottom;
@property (nonatomic) CGFloat margin_right;

// space between line chart and volume chart
@property (nonatomic) CGFloat space;

@property (nonatomic, strong) UIColor *boundColor;
@property (nonatomic) CGFloat boundWidth;
// if true than draw inner grid
@property (nonatomic) BOOL drawInnerGrid;
@property (nonatomic, strong) UIColor *innerGridColor;
@property (nonatomic) CGFloat innerGridWidth;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *avgLineColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic) NSUInteger days;
@property (nonatomic) NSUInteger interval;

- (void)loadDataWithSecuCode:(NSString *)code;

@end
