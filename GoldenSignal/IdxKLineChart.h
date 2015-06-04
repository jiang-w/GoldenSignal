//
//  IdxKLineChart.h
//  GoldenSignal
//
//  Created by Frank on 15/6/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IdxKLineChart : UIView

@property (nonatomic) int verticalGridStep;
@property (nonatomic) int horizontalGridStep;
@property (nonatomic) CGFloat margin;

@property (nonatomic, strong) UIColor* boundColor;
@property (nonatomic) CGFloat boundLineWidth;
@property (nonatomic) BOOL drawInnerGrid;
@property (nonatomic, strong) UIColor* innerGridColor;
@property (nonatomic) CGFloat innerGridLineWidth;


- (id)initWithFrame:(CGRect)frame andIdxCode:(NSString *)code;

@end
