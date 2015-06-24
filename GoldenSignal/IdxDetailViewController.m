//
//  IdxDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxDetailViewController.h"
#import "IdxQuoteView.h"
#import "TrendLineChart.h"
#import <Masonry.h>

@interface IdxDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) IdxQuoteView *idxQuoteView;
@property(nonatomic, strong) TrendLineChart *trendLineChart;

@end

@implementation IdxDetailViewController
{
    NSString *_code;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
}

- (void)settingView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(self.view);
    }];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    /* 添加指数标价 */
    self.idxQuoteView = [IdxQuoteView createView];
    [self.idxQuoteView subscribeIndicatorsWithCode:@"000001.SHI"];
    [self addSubView:self.idxQuoteView withHeight:110 andSpace:0];
    
    /* 添加指数走势图 */
    self.trendLineChart = [[TrendLineChart alloc] init];
    self.trendLineChart.margin = 6;
    [self addSubView:self.trendLineChart withHeight:180 andSpace:0];
    
    UIView *lastView = self.containerView.subviews.lastObject;
    if (lastView) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastView.mas_bottom);
        }];
    }
}

- (void)addSubView:(UIView *) subView withHeight:(CGFloat)height andSpace:(CGFloat)space {
    UIView *lastView = self.containerView.subviews.lastObject;
    if (subView) {
        [self.containerView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(space);
            }
            else {
                make.top.equalTo(self.containerView).with.offset(space);
            }
            make.left.and.right.equalTo(self.containerView);
            make.height.mas_equalTo(height);
        }];
    }
}

- (void)loadDataWithCode:(NSString *)code {
//    if (![code isEqualToString:_code]) {
//        BDSecuCode *secuCode = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
//        if (secuCode) {
//            _code = code;
//            [self.idxQuoteView subscribeIndicatorsWithCode:code];
//        }
//    }
}

@end
