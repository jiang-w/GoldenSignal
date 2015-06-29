//
//  IdxTrendView.h
//  GoldenSignal
//
//  Created by Frank on 15/6/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteHomeTrendChart : UIView

@property (nonatomic) int verticalGridStep;
@property (nonatomic) int horizontalGridStep;
@property (nonatomic) CGFloat margin;

@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) CGFloat lineWidth;

@property (nonatomic, strong) UIColor* boundColor;
@property (nonatomic) CGFloat boundLineWidth;
@property (nonatomic) BOOL drawInnerGrid;
@property (nonatomic, strong) UIColor* innerGridColor;
@property (nonatomic) CGFloat innerGridLineWidth;


- (id)initWithFrame:(CGRect)frame andIdxCode:(NSString *)code;

@end
