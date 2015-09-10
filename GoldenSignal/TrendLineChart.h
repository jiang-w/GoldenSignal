//
//  TrendLineChart.h
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendLineViewModel.h"

@interface TrendLineChart : UIView

// margin with bound
@property(nonatomic) CGMargin margin;
// space between line chart and volume chart
@property(nonatomic) CGFloat space;

@property(nonatomic, strong) UIColor *boundColor;
@property(nonatomic) CGFloat boundWidth;
// if true than draw inner grid
@property(nonatomic) BOOL drawInnerGrid;
@property(nonatomic, strong) UIColor *innerGridColor;
@property(nonatomic) CGFloat innerGridWidth;

@property(nonatomic, strong) UIColor *lineColor;
@property(nonatomic, strong) UIColor *avgLineColor;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic, strong) UIColor *fillColor;


- (instancetype)initWithFrame:(CGRect)frame andViewModel:(TrendLineViewModel *)viewModel;

@end
