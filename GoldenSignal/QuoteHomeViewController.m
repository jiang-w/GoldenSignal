//
//  QuoteHomeViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/6/2.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteHomeViewController.h"
#import "QuoteHomeTrendView.h"
#import "QuoteHomeKLineView.h"
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
        QuoteHomeTrendView *trend = [QuoteHomeTrendView createViewWithIdxCode:key];
        [contain addSubview:trend];
        [trend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.and.right.equalTo(contain);
        }];
        
        QuoteHomeKLineView *kLine = [QuoteHomeKLineView createViewWithIdxCode:key];
        [contain addSubview:kLine];
        [kLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.and.right.equalTo(contain);
        }];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        if ([dateString intValue] > 93000) {
            [contain exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapBoardView:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    [UIView transitionWithView:view duration:1.0 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        [view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    } completion:nil];
}

@end
