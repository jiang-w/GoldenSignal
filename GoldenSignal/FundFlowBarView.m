//
//  FundFlowBarChart1.m
//  GoldenSignal
//
//  Created by Frank on 15/7/14.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowBarView.h"
#import "BarView.h"
#import "FundFlowBarChart.h"
#import <Masonry.h>

@interface FundFlowBarView ()

@property (weak, nonatomic) IBOutlet UIView *chart;
@property (weak, nonatomic) IBOutlet UILabel *date1;
@property (weak, nonatomic) IBOutlet UILabel *date2;
@property (weak, nonatomic) IBOutlet UILabel *date3;
@property (weak, nonatomic) IBOutlet UILabel *date4;
@property (weak, nonatomic) IBOutlet UILabel *date5;


@end

@implementation FundFlowBarView
{
    NSMutableArray *_dataArray;
    NSMutableArray *_barArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutDateLabel];
    
    NSComparator cmptr = ^(id obj1, id obj2){
        if (fabs([obj1 doubleValue]) > fabs([obj2 doubleValue])) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (fabs([obj1 doubleValue]) < fabs([obj2 doubleValue])) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *array = [_dataArray sortedArrayUsingComparator:cmptr];
    double max = fabs([[array lastObject] doubleValue]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataWithSecuCode:(NSString *)code {
//    NSArray *data = @[[NSNumber numberWithFloat:6259.6], [NSNumber numberWithFloat:44116.6], [NSNumber numberWithFloat:29173.6], [NSNumber numberWithFloat: -9026.2], [NSNumber numberWithFloat: -13170.5]];
    NSArray *data = @[[NSNumber numberWithFloat:0.14], [NSNumber numberWithFloat:0.25], [NSNumber numberWithFloat:0.75], [NSNumber numberWithFloat: -0.34], [NSNumber numberWithFloat: -0.1]];
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:data];
    
    [self addBarViews];
}

- (void)layoutDateLabel {
//    NSMutableArray *labelArray = [NSMutableArray array];
//    [labelArray addObject:self.date1];
//    [labelArray addObject:self.date2];
//    [labelArray addObject:self.date3];
//    [labelArray addObject:self.date4];
//    [labelArray addObject:self.date5];
//    
//    CGFloat barWidth = CGRectGetWidth(self.chart.frame) / 10;
//    for (int i = 0; i < 5; i++) {
//        CGFloat xCenterOffset = CGRectGetMinX(self.chart.frame) + barWidth * (i * 2 +1);
//        UILabel *dateLabel = labelArray[i];
//        if (dateLabel) {
//            [dateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.view.mas_left).with.offset(xCenterOffset);
//                make.top.equalTo(self.chart.mas_bottom).with.offset(8);
//            }];
//        }
//    }
}

- (void)addBarViews {
    NSMutableArray *barArray = [NSMutableArray array];
    for (int i = 0; i < _dataArray.count; i++) {
        float val = [_dataArray[i] floatValue];
        BarView *bar = [[BarView alloc] init];
        bar.grade = val;
        if (val > 0) {
            bar.barColor = [UIColor redColor];
        }
        else {
            bar.barColor = [UIColor greenColor];
        }
        [barArray addObject:bar];
    }
    
    [self makeEqualWidthViews:barArray inView:self.chart withMargin:CGMarginZero andSpacing:20];
}

/**
 *  将若干view等宽布局于容器containerView中
 *
 *  @param views         viewArray
 *  @param containerView 容器view
 *  @param margin        距容器的上下左右边距
 *  @param spacing       各view左右间距
 */
- (void)makeEqualWidthViews:(NSArray *)views inView:(UIView *)containerView withMargin:(CGMargin)margin andSpacing:(CGFloat)spacing {
    UIView *lastView = nil;
    for (UIView *view in views) {
        [containerView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.equalTo(lastView.mas_right).offset(spacing);
                make.width.equalTo(lastView);
            }
            else {
                make.left.equalTo(containerView).offset(margin.left);
            }
            
            float val = ((BarView *)view).grade;
            if (val > 0) {
                make.top.equalTo(containerView).offset(margin.top);
                make.bottom.equalTo(containerView.mas_top).offset(CGRectGetHeight(containerView.frame) / 2);
            }
            else {
                make.top.equalTo(containerView).offset(CGRectGetHeight(containerView.frame) / 2);
                make.bottom.equalTo(containerView).offset(-margin.bottom);
            }
        }];
        
        lastView=view;
    }
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-margin.right);
    }];
}


@end
