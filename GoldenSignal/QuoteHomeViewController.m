//
//  QuoteHomeViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/6/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteHomeViewController.h"
#import "IdxTrendView.h"
#import "IdxKLineView.h"
#import <Masonry.h>

@interface QuoteHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *ltBoardView;
@property (weak, nonatomic) IBOutlet UIView *rtBoardView;
@property (weak, nonatomic) IBOutlet UIView *lmBoardView;
@property (weak, nonatomic) IBOutlet UIView *rmBoardView;
@property (weak, nonatomic) IBOutlet UIView *lbBoardView;
@property (weak, nonatomic) IBOutlet UIView *rbBoardView;

@end

@implementation QuoteHomeViewController
{
    NSDictionary *_idxCodesDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _idxCodesDic = @{@"000001.SHI":_ltBoardView,
                     @"399001.SZI":_rtBoardView,
                     @"399006.SZI":_lmBoardView,
                     @"399005.SZI":_rmBoardView,
                     @"000016.SHI":_lbBoardView,
                     @"000300.CSI":_rbBoardView
                     };

    [self addChartViews];
}

- (void)addChartViews {
    for (NSString *key in [_idxCodesDic allKeys]) {
        UIView *contain = _idxCodesDic[key];
        IdxTrendView *trend = [IdxTrendView createViewWithIdxCode:key];
        [contain addSubview:trend];
        [trend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.and.right.equalTo(contain);
        }];
        
//        IdxKLineView *kLine = [IdxKLineView createViewWithIdxCode:key];
//        [contain addSubview:kLine];
//        [kLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.bottom.and.right.equalTo(contain);
//        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapBoardView:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    CGContextRef context=UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:YES];
    [view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

@end
