//
//  KLineChart.h
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLineChart : UIView

// margin with bound
@property(nonatomic) CGFloat margin;
@property(nonatomic) CGFloat margin_top;
@property(nonatomic) CGFloat margin_left;
@property(nonatomic) CGFloat margin_bottom;
@property(nonatomic) CGFloat margin_right;

// space between line chart and volume chart
@property (nonatomic) CGFloat space;

@property(nonatomic, strong) UIColor *boundColor;
@property(nonatomic) CGFloat boundWidth;
// if true than draw inner grid
@property(nonatomic) BOOL drawInnerGrid;
@property(nonatomic, strong) UIColor *innerGridColor;
@property(nonatomic) CGFloat innerGridWidth;
// UILabel Font
@property(nonatomic, strong) UIFont *labelFont;

@property(nonatomic, assign) KLineType type;
@property(nonatomic, assign) NSUInteger number;


- (void)loadDataWithSecuCode:(NSString *)code;

@end
