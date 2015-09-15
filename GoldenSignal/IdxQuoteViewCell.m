//
//  IdxQuoteViewCell.m
//  GoldenSignal
//
//  Created by Frank on 15/6/8.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxQuoteViewCell.h"
#import "IdxQuoteCellViewModel.h"
#import "LiteTrendView.h"
#import "LiteKLineView.h"
#import <FBKVOController.h>

@implementation IdxQuoteViewCell
{
    IdxQuoteCellViewModel *_vm;
    FBKVOController *_kvo;
}

- (void)awakeFromNib {
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setCode:(NSString *)code {
    if (code != nil && ![code isEqualToString:_code]) {
        _code = [code copy];
        if (_vm == nil) {
            _vm = [[IdxQuoteCellViewModel alloc] init];
            [self kvoController];
        }
        
        [_vm subscribeQuotationScalarWithCode:_code];
        [self addTrendViewWithCode:_code];
        [self addKLineViewWithCode:_code];
    }
}

- (void)addTrendViewWithCode:(NSString *)code {
    [self.trendView removeFromSuperview];
    CGRect frame = self.trendView.frame;
    self.trendView = [[LiteTrendView alloc] initWithFrame:frame andCode:code];
    [self addSubview:self.trendView];
}

- (void)addKLineViewWithCode:(NSString *)code {
    [self.kLineView removeFromSuperview];
    CGRect frame = self.kLineView.frame;
    self.kLineView = [[LiteKLineView alloc] initWithFrame:frame andCode:code];
    [self addSubview:self.kLineView];
}

- (void)kvoController {
    if (_vm) {
        //  股票名称
        [_kvo observe:_vm keyPath:@"Name" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *name = [model.Name stringByReplacingOccurrencesOfString:@"申万一级" withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@"申万" withString:@""];
                view.name.text = name != nil ? name : @"—";
            });
        }];
        //  交易代码
        [_kvo observe:_vm keyPath:@"TrdCode" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.trdCode.text = model.TrdCode != nil ? model.TrdCode : @"—";
            });
        }];
        //  涨跌幅
        [_kvo observe:_vm keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double changeRange = model.ChangeRange * 100.0;
                if ([[NSString stringWithFormat:@"%f", changeRange] isEqualToString:@"inf"]
                    || [[NSString stringWithFormat:@"%f", changeRange] isEqualToString:@"nan"]) {
                    view.changeRange.text = @"—";
                }
                else {
                    view.changeRange.text = [NSString stringWithFormat:@"%.2f%%", changeRange];
                }
                // 设置背景色
                if (changeRange > 0) {
                    view.changeRange.superview.backgroundColor = RGB(204.0, 21.0, 21.0);
                }
                else if (changeRange < 0) {
                    view.changeRange.superview.backgroundColor = RGB(41.0, 152.0, 8.0);
                }
                else if (changeRange == 0) {
                    view.changeRange.superview.backgroundColor = RGB(43.0, 176.0, 241.0);
                }
                else {
                    view.changeRange.superview.backgroundColor = [UIColor clearColor];
                }
            });
        }];
        //  当前价
        [_kvo observe:_vm keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.now.text = model.Now != 0 ? [NSString stringWithFormat:@"%.2f", model.Now] : @"—";
            });
        }];
        //  成交量
        [_kvo observe:_vm keyPath:@"Volume" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double val = model.Volume / 1000000.0;
                if (val >= 10000) {
                    view.volume.text =  [NSString stringWithFormat:@"%.3f亿", val / 10000];
                }
                else if (val > 0) {
                    view.volume.text = [NSString stringWithFormat:@"%.0f万", val];
                }
                else {
                    view.volume.text = @"—";
                }
            });
        }];
        //  成交量
        [_kvo observe:_vm keyPath:@"Amount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double val = model.Amount / 1000000000;
                if (val > 0) {
                    view.amount.text = [NSString stringWithFormat:@"%.0f亿", val];
                }
                else {
                    view.amount.text = @"—";
                }
            });
        }];
        //  上涨家数
        [_kvo observe:_vm keyPath:@"UpCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.UpCount > 0) {
                    view.upCount.text = [NSString stringWithFormat:@"%d家", model.UpCount];
                }
                else {
                    view.upCount.text = @"—";
                }
            });
        }];
        //  平盘家数
        [_kvo observe:_vm keyPath:@"SameCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.SameCount > 0) {
                    view.sameCount.text = [NSString stringWithFormat:@"%d家", model.SameCount];
                }
                else {
                    view.sameCount.text = @"—";
                }
            });
        }];
        //  下跌家数
        [_kvo observe:_vm keyPath:@"DownCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteViewCell *view, IdxQuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.DownCount > 0) {
                    view.downCount.text = [NSString stringWithFormat:@"%d家", model.DownCount];
                }
                else {
                    view.downCount.text = @"—";
                }
            });
        }];
    }
}

- (void)dealloc {
    NSLog(@"IdxQuoteViewCell dealloc (%@)", _code);
}

@end
