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
#import "BDKeyboardWizard.h"

#import <Masonry.h>
#import <MBProgressHUD.h>

@interface FundFlowBarView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *chart;
@property (weak, nonatomic) IBOutlet UILabel *date1;
@property (weak, nonatomic) IBOutlet UILabel *date2;
@property (weak, nonatomic) IBOutlet UILabel *date3;
@property (weak, nonatomic) IBOutlet UILabel *date4;
@property (weak, nonatomic) IBOutlet UILabel *date5;

@end

@implementation FundFlowBarView
{
    NSMutableArray *_valueArray;
    NSMutableArray *_dateArray;
    NSMutableArray *_barArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _valueArray = [NSMutableArray array];
    _dateArray = [NSMutableArray array];
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
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
    NSArray *idxList = @[@"000001", @"000002", @"000003", @"000010", @"000016", @"000043", @"000300", @"000903", @"000905", @"399001", @"399004", @"399005", @"399006", @"399100", @"399101", @"399102", @"399106", @"399107", @"399108"];
    NSArray *data;
    if ([idxList containsObject:secu.trdCode]) {    // 是否为市场指数
        self.titleLabel.text = @"沪深A股近期大单资金流向";
        NSDictionary *paramDic = @{@"days": [NSNumber numberWithUnsignedInteger:5]};
        data = [[BDCoreService new] syncRequestDatasourceService:1593 parameters:paramDic query:nil];
    }
    else {
        self.titleLabel.text = @"行业近期大单资金流向";
        NSDictionary *paramDic = @{@"BD_CODE": [NSString stringWithFormat:@"'%@'",code],
                                   @"days": [NSNumber numberWithUnsignedInteger:5]};
        data = [[BDCoreService new] syncRequestDatasourceService:1587 parameters:paramDic query:nil];
    }
    [_valueArray removeAllObjects];
    [_dateArray removeAllObjects];
    for (NSDictionary *item in data) {
        NSString *date = item[@"TRD_DT"];
        float value = [item[@"MNY_NET"] floatValue];
        [_valueArray addObject:[NSNumber numberWithFloat:value]];
        [_dateArray addObject:date];
    }
}

- (float)maxRange {
    NSComparator cmptr = ^(id obj1, id obj2){
        if (fabs([obj1 floatValue]) > fabs([obj2 floatValue])) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (fabs([obj1 floatValue]) < fabs([obj2 floatValue])) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *array = [_valueArray sortedArrayUsingComparator:cmptr];
    return fabs([[array lastObject] floatValue]);
}

- (CGMargin)margin {
    return CGMarginMake(0, 10, 0, 10);
}

- (void)addBarViews {
    float maxRange = [self maxRange];
    CGMargin margin = [self margin];
    for (int i = 0; i < _valueArray.count; i++) {
        float val = [_valueArray[i] floatValue];
        BarView *bar = [[BarView alloc] init];
        bar.grade = val / maxRange;
        if (val > 0) {
            bar.color = [UIColor redColor];
        }
        else {
            bar.color = [UIColor greenColor];
        }
        [_barArray addObject:bar];
    }
    [self makeEqualWidthViews:_barArray inView:self.chart withMargin:margin andSpacing:20];
}

- (void)addLabels {
    NSArray *dateLabelArray = @[_date1, _date2, _date3, _date4, _date5];
    for (int i = 0; i < _barArray.count; i++) {
        BarView *bar = _barArray[i];
        UILabel *label = [[UILabel alloc] init];
        [bar.superview addSubview:label];
        label.text = [NSString stringWithFormat:@"%.2f", [_valueArray[i] floatValue]];
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

        UILabel *dateLabel = dateLabelArray[i];
        dateLabel.text = _dateArray[i];
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
