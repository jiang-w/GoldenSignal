//
//  IdxTrendView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteHomeTrendView.h"
#import "QuoteHomeTrendViewModel.h"
#import "QuoteHomeTrendChart.h"
#import <FBKVOController.h>
#import <Masonry.h>

@implementation QuoteHomeTrendView
{
    QuoteHomeTrendViewModel *_viewModel;
    FBKVOController *_kvo;
}

+ (QuoteHomeTrendView *)createViewWithIdxCode:(NSString *)code
{
    QuoteHomeTrendView * view = [[[NSBundle mainBundle] loadNibNamed:@"QuoteHomeTrendView" owner:nil options:nil] objectAtIndex:0];
    [view subscribeDataWithCode:code];
    return view;
}

- (void)awakeFromNib {
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (void)subscribeDataWithCode:(NSString *)code {
    if (_viewModel == nil) {
        _viewModel = [[QuoteHomeTrendViewModel alloc] init];
        [self kvoController];
    }
    [_viewModel subscribeQuotationScalarWithCode:code];
    [self addTrendViewWithCode:code];
}

- (void)addTrendViewWithCode:(NSString *)code {
    for (UIView *sub in self.chart.subviews) {
        [sub removeFromSuperview];
    }
    QuoteHomeTrendChart *chartView = [[QuoteHomeTrendChart alloc] initWithFrame:CGRectZero andIdxCode:code];
    [self.chart addSubview:chartView];
    [chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(self.chart);
    }];
}

- (void)kvoController {
    if (_viewModel) {
        [_kvo observe:_viewModel keyPath:@"Code" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.code.text = [NSString stringWithFormat:@"%@", change[NSKeyValueChangeNewKey]];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Name" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.name.text = [NSString stringWithFormat:@"%@", change[NSKeyValueChangeNewKey]];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Open" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double open = [change[NSKeyValueChangeNewKey] doubleValue];
                self.open.text = [NSString stringWithFormat:@"%.2f", open];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double nowPrice = [change[NSKeyValueChangeNewKey] doubleValue];
                self.now.text = [NSString stringWithFormat:@"%.2f", nowPrice];
//                self.now.font = [UIFont systemFontOfSize:16 weight:0.5]; // IOS8.2
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Change" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double changeVal = [change[NSKeyValueChangeNewKey] doubleValue];
                self.change.text = [NSString stringWithFormat:@"%.2f", changeVal];
                self.head.backgroundColor = [self textColorValue:changeVal otherValue:0];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double changeRange = [change[NSKeyValueChangeNewKey] doubleValue] * 100;
                self.changeRange.text = isnan(changeRange) ? @"0.00%" : [NSString stringWithFormat:@"%.2f%%", changeRange];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Volume" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double volume = [change[NSKeyValueChangeNewKey] unsignedIntValue] / 1000000.0;
                if (volume > 0) {
                    if (volume >= 10000) {
                        self.volume.text = [NSString stringWithFormat:@"%.3f亿", volume / 10000];
                    }
                    else {
                        self.volume.text = [NSString stringWithFormat:@"%.0f万", volume];
                    }
                }
                else {
                    self.volume.text = @"—";
                }
            });
        }];
    }
}

- (UIColor *)textColorValue:(float)val1 otherValue:(float)val2 {
    if (val1 > val2) {
        return RGB(204, 21, 21);
    }
    else if (val1 < val2) {
        return RGB(41, 152, 8);
    }
    else {
        return RGB(43, 176, 241);
    }
}

@end
