//
//  LiteStkQuoteViewCell.m
//  GoldenSignal
//
//  Created by Frank on 15/7/8.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "RankingListCell.h"
#import "RankingListCellViewModel.h"
#import <FBKVOController.h>

@implementation RankingListCell
{
    RankingListCellViewModel *_vm;
    FBKVOController *_kvo;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    _vm = [[RankingListCellViewModel alloc] init];
    _kvo = [FBKVOController controllerWithObserver:self];
    [self kvoController];
}

- (void)setCode:(NSString *)code {
    if (code != nil && ![code isEqualToString:_code]) {
        _code = [code copy];
        [_vm loadDataWithCode:_code];
    }
}

- (void)kvoController {
    if (_vm) {
        //  股票名称
        [_kvo observe:_vm keyPath:@"Name" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(RankingListCell *view, RankingListCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.name.text = model.Name != nil ? model.Name : @"—";
            });
        }];
        //  交易代码
        [_kvo observe:_vm keyPath:@"TrdCode" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(RankingListCell *view, RankingListCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.trdCode.text = model.TrdCode != nil ? model.TrdCode : @"—";
            });
        }];
        //  当前价
        [_kvo observe:_vm keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(RankingListCell *view, RankingListCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.now.text = model.Now != 0 ? [NSString stringWithFormat:@"%.2f", model.Now] : @"—";
            });
        }];
        //  涨跌幅
        [_kvo observe:_vm keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(RankingListCell *view, RankingListCellViewModel *model, NSDictionary *change) {
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
                    view.now.textColor = view.changeRange.textColor = view.change.textColor = RGB(204, 21, 21);
                }
                else if (changeRange < 0) {
                    view.now.textColor = view.changeRange.textColor = view.change.textColor = RGB(41, 152, 8);
                }
                else {
                    view.now.textColor = view.changeRange.textColor = view.change.textColor = RGB(43, 176, 241);
                }
            });
        }];
        //  涨跌
        [_kvo observe:_vm keyPath:@"Change" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(RankingListCell *view, RankingListCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.change.text = model.Change != 0 ? [NSString stringWithFormat:@"%.2f", model.Change] : @"—";
            });
        }];
    }
}

- (void)dealloc {
//    NSLog(@"RankingListCell dealloc (%@)", _code);
}

@end
