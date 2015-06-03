//
//  IdxTrendView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxTrendView.h"
#import "IdxTrendViewModel.h"
#import "IdxTrendChart.h"
#import <FBKVOController.h>
#import <Masonry.h>

@implementation IdxTrendView
{
    IdxTrendViewModel *_viewModel;
    FBKVOController *_kvo;
}

+ (IdxTrendView *)createViewWithIdxCode:(NSString *)code
{
    IdxTrendView * view = [[[NSBundle mainBundle] loadNibNamed:@"IdxTrendView" owner:nil options:nil] objectAtIndex:0];
    [view subscribeDataWithCode:code];
    return view;
}

- (void)awakeFromNib {
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (NSString *)code {
    if (_viewModel) {
        return _viewModel.Code;
    }
    else {
        return nil;
    }
}

- (void)subscribeDataWithCode:(NSString *)code {
    if (_viewModel == nil) {
        _viewModel = [[IdxTrendViewModel alloc] init];
        [self kvoController];
    }
    self.code.text = code;
    [_viewModel subscribeQuotationScalarWithCode:code];
    [self addTrendViewWithCode:code];
}

- (void)addTrendViewWithCode:(NSString *)code {
    for (UIView *sub in self.chart.subviews) {
        [sub removeFromSuperview];
    }
    IdxTrendChart *chartView = [[IdxTrendChart alloc] initWithFrame:CGRectZero andIdxCode:code];
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
        
        [_kvo observe:_viewModel keyPath:@"Open" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float open = [change[NSKeyValueChangeNewKey] floatValue];
                self.open.text = [NSString stringWithFormat:@"%.2f", open];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float nowPrice = [change[NSKeyValueChangeNewKey] floatValue];
                self.now.text = [NSString stringWithFormat:@"%.2f", nowPrice];
                self.head.backgroundColor = [self textColorValue:nowPrice otherValue:_viewModel.PrevClose];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Change" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float changeVal = [change[NSKeyValueChangeNewKey] floatValue];
                self.change.text = [NSString stringWithFormat:@"%.2f", changeVal];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float changeRange = [change[NSKeyValueChangeNewKey] floatValue] * 100;
                self.changeRange.text = [NSString stringWithFormat:@"%.2f%%", changeRange];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Volume" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float volume = [change[NSKeyValueChangeNewKey] floatValue] / 1000000.0;
                if (volume > 0) {
                    if (volume >= 10000) {
                        self.volume.text = [NSString stringWithFormat:@"%.3f亿", volume/10000.0];
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
