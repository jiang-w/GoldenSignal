//
//  QuoteViewCell.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteViewCell.h"
#import "QuoteCellViewModel.h"
#import "LiteTrendView.h"
#import "LiteKLineView.h"
#import <FBKVOController.h>

@implementation QuoteViewCell
{
    QuoteCellViewModel *_viewModel;
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
        if (_viewModel == nil) {
            _viewModel = [[QuoteCellViewModel alloc] init];
            [self kvoController];
        }
        
        [_viewModel subscribeQuotationScalarWithCode:_code];
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
    if (_viewModel) {
        //  股票名称
        [_kvo observe:_viewModel keyPath:@"Name" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.name.text = model.Name != nil ? _viewModel.Name : @"—";
                NSInteger index = model.Code.length - 3;
                view.trdCode.text = [model.Code substringToIndex:index];
            });
        }];
        //  当前价
        [_kvo observe:_viewModel keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.now.text = _viewModel.Now != 0 ? [NSString stringWithFormat:@"%.2f", model.Now] : @"—";
            });
        }];
        //  涨跌幅
        [_kvo observe:_viewModel keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat changeRange = model.ChangeRange * 100.0;
                if ([[NSString stringWithFormat:@"%f", changeRange] isEqualToString:@"inf"]
                    || [[NSString stringWithFormat:@"%f", changeRange] isEqualToString:@"nan"]) {
                    view.changeRange.text = @"—";
                }
                else {
                    view.changeRange.text = [NSString stringWithFormat:@"%.2f%%", changeRange];
                }
                // 设置背景色
                if (changeRange > 0) {
                    view.now.superview.backgroundColor = RGB(204.0, 21.0, 21.0, 1.0);
                }
                else if (changeRange < 0) {
                    view.now.superview.backgroundColor = RGB(41.0, 152.0, 8.0, 1.0);
                }
                else if (changeRange == 0) {
                    view.now.superview.backgroundColor = RGB(43.0, 176.0, 241.0, 1.0);
                }
                else {
                    view.now.superview.backgroundColor = [UIColor clearColor];
                }
            });
        }];
        //  现量
        [_kvo observe:_viewModel keyPath:@"VolumeSpread" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.volume.text = model.VolumeSpread != 0 ? [NSString stringWithFormat:@"%d", model.VolumeSpread / 100] : @"—";
            });
        }];
        //  总市值（亿）
        [_kvo observe:_viewModel keyPath:@"TtlAmount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.ttlAmount.text = model.TtlAmount != 0 ? [NSString stringWithFormat:@"%.0f亿", model.TtlAmount] : @"—";
            });
        }];
        //  市盈率
        [_kvo observe:_viewModel keyPath:@"PEttm" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.pettm.text = [NSString stringWithFormat:@"%.2f", model.PEttm];
            });
        }];
        //  新闻事件评级
        [_kvo observe:_viewModel keyPath:@"NewsRatingLevel" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                int level = model.NewsRatingLevel;
                switch (level) {
                    case 2:
                        view.level.text = @"正+";
                        view.level.superview.backgroundColor = RGB(204.0, 21.0, 21.0, 1.0);
                        break;
                    case 1:
                        view.level.text = @"正";
                        view.level.superview.backgroundColor = RGB(204.0, 21.0, 21.0, 1.0);
                        break;
                    case 0:
                        view.level.text = @"中";
                        view.level.superview.backgroundColor = RGB(43.0, 176.0, 241.0, 1.0);
                        break;
                    case -1:
                        view.level.text = @"负";
                        view.level.superview.backgroundColor = RGB(41.0, 152.0, 8.0, 1.0);
                        break;
                    case -2:
                        view.level.text = @"负-";
                        view.level.superview.backgroundColor = RGB(41.0, 152.0, 8.0, 1.0);
                        break;
                    default:
                        break;
                }
            });
        }];
        //  新闻事件分类
        [_kvo observe:_viewModel keyPath:@"NewsRatingName" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *label = @"";
                NSRange range = [model.NewsRatingName rangeOfString:@" | "];
                if (range.length > 0) {
                    label = [model.NewsRatingName substringToIndex:range.location];
                }
                else {
                    label = model.NewsRatingName;
                }
                view.label.text = label;
            });
        }];
        //  新闻事件日期
        [_kvo observe:_viewModel keyPath:@"NewsRatingDate" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(QuoteViewCell *view, QuoteCellViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.NewsRatingDate != 0) {
                    NSMutableString *date =[NSMutableString stringWithFormat:@"%d", model.NewsRatingDate];
                    [date insertString:@"-" atIndex:4];
                    [date insertString:@"-" atIndex:7];
                    view.date.text = date;
                }
                else {
                    view.date.text = @"—";
                }
            });
        }];
        
    }
}

@end
