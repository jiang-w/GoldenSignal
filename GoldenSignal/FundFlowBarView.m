//
//  FundFlowBarChart1.m
//  GoldenSignal
//
//  Created by Frank on 15/7/14.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowBarView.h"
#import "BarView.h"
#import "BDCoreService.h"

#import <Masonry.h>
#import <MBProgressHUD.h>

@interface FundFlowBarView ()

@property (weak, nonatomic) IBOutlet UIView *chart;
@property (weak, nonatomic) IBOutlet UILabel *date1;

@end

@implementation FundFlowBarView
{
    NSMutableArray *_dataArray;
    NSMutableArray *_barArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _barArray = [NSMutableArray array];
    if (self.code) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.chart animated:YES];
        hud.opacity = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self loadDataWithSecuCode:self.code];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addBarViews];
                [self addLabels];
                [MBProgressHUD hideHUDForView:self.chart animated:YES];
            });
        });
    }
}

- (void)loadDataWithSecuCode:(NSString *)code {
//    NSDictionary *paramDic = @{@"BD_CODE": [NSString stringWithFormat:@"\'%@\'",code]};
//    NSArray *data = [[BDCoreService new] syncRequestDatasourceService:1587 parameters:paramDic query:nil];
//    NSArray *data = @[[NSNumber numberWithFloat:6259.6], [NSNumber numberWithFloat:44116.6], [NSNumber numberWithFloat:29173.6], [NSNumber numberWithFloat: -9026.2], [NSNumber numberWithFloat: -13170.5]];
    NSArray *data = @[[NSNumber numberWithFloat:0.14], [NSNumber numberWithFloat:0.25 ], [NSNumber numberWithFloat:0.75], [NSNumber numberWithFloat: -0.34], [NSNumber numberWithFloat: -0.1]];
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:data];
}

- (void)addBarViews {
    for (int i = 0; i < _dataArray.count; i++) {
        float val = [_dataArray[i] floatValue];
        BarView *bar = [[BarView alloc] init];
        bar.grade = val;
        if (val > 0) {
            bar.color = [UIColor redColor];
        }
        else {
            bar.color = [UIColor greenColor];
        }
        [_barArray addObject:bar];
    }
    
    [self makeEqualWidthViews:_barArray inView:self.chart withMargin:CGMarginMake(0, 10, 0, 10) andSpacing:20];
}

- (void)addLabels {
    for (BarView *bar in _barArray) {
        UILabel *label = [[UILabel alloc] init];
        [bar.superview addSubview:label];
        label.text = [NSString stringWithFormat:@"%.2f", bar.grade];
        label.font = [UIFont systemFontOfSize:8];
        if (bar.grade > 0) {
            label.textColor = [UIColor redColor];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bar.mas_bottom).offset(4);
                make.centerX.equalTo(bar);
            }];
        }
        else {
            label.textColor = [UIColor greenColor];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(bar.mas_top).offset(-4);
                make.centerX.equalTo(bar);
            }];
        }

    }
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
