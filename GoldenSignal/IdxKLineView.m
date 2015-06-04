//
//  IdxKLineView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxKLineView.h"
#import "IdxKLineViewModel.h"
#import "IdxKLineChart.h"
#import <FBKVOController.h>
#import <Masonry.h>

@implementation IdxKLineView
{
    IdxKLineViewModel *_viewModel;
    FBKVOController *_kvo;
}

+ (IdxKLineView *)createViewWithIdxCode:(NSString *)code
{
    IdxKLineView * view = [[[NSBundle mainBundle] loadNibNamed:@"IdxKLineView" owner:nil options:nil] objectAtIndex:0];
    [view subscribeDataWithCode:code];
    return view;
}

- (void)awakeFromNib {
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (void)subscribeDataWithCode:(NSString *)code {
    if (_viewModel == nil) {
        _viewModel = [[IdxKLineViewModel alloc] init];
        [self kvoController];
    }
    [_viewModel subscribeQuotationScalarWithCode:code];
    [self addKLineViewWithCode:code];
}

- (void)addKLineViewWithCode:(NSString *)code {
    for (UIView *sub in self.chart.subviews) {
        [sub removeFromSuperview];
    }
    IdxKLineChart *chartView = [[IdxKLineChart alloc] initWithFrame:CGRectZero andIdxCode:code];
    [self.chart addSubview:chartView];
    [chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(self.chart);
    }];
}

- (void)kvoController {
    if (_viewModel) {
        [_kvo observe:_viewModel keyPath:@"Name" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.name.text = [NSString stringWithFormat:@"%@", change[NSKeyValueChangeNewKey]];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float nowPrice = [change[NSKeyValueChangeNewKey] floatValue];
                self.now.text = [NSString stringWithFormat:@"%.2f", nowPrice];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Change" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float changeVal = [change[NSKeyValueChangeNewKey] floatValue];
                self.change.text = [NSString stringWithFormat:@"%.2f", changeVal];
                self.head.backgroundColor = [self textColorValue:changeVal otherValue:0];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float changeRange = [change[NSKeyValueChangeNewKey] floatValue] * 100;
                self.changeRange.text = [NSString stringWithFormat:@"(%.2f%%)", changeRange];
            });
        }];
    }
}

- (UIColor *)textColorValue:(float)val1 otherValue:(float)val2 {
    if (val1 > val2) {
        return RGB(204.0, 21.0, 21.0, 1.0);
    }
    else if (val1 < val2) {
        return RGB(41.0, 152.0, 8.0, 1.0);
    }
    else {
        return RGB(43.0, 176.0, 241.0, 1.0);
    }
}

@end
