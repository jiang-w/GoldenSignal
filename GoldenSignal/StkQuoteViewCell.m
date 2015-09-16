//
//  StkQuoteViewCell.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "StkQuoteViewCell.h"
#import "StkQuoteCellViewModel.h"
#import "LiteTrendView.h"
#import "LiteKLineView.h"

#import <ReactiveCocoa.h>

@interface StkQuoteViewCell()

@property(nonatomic, strong) StkQuoteCellViewModel *viewModel;

@end

@implementation StkQuoteViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)subscribeDataWithSecuCode:(NSString *)code {
    if (code && ![code isEqualToString:self.viewModel.Code]) {
        self.viewModel = [[StkQuoteCellViewModel alloc] initWithCode:code];
        
        //        [self addTrendViewWithCode:code];
        //        [self addKLineViewWithCode:code];
    }
    
    @weakify(self);
    //  证券编码
    RAC(self, secuCode) = [[RACObserve(self.viewModel, Code) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
    //  股票名称
    RAC(self.name, text, @"-") = [[RACObserve(self.viewModel, Name) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
    //  交易代码
    RAC(self.trdCode, text, @"-") = [[RACObserve(self.viewModel, TrdCode) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
    //  当前价
    RAC(self.now, text, @"-") = [[[RACObserve(self.viewModel, Now) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    //  涨跌幅
    RAC(self.changeRange, text, @"-") = [[[RACObserve(self.viewModel, ChangeRange) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
                                         map:^id(id value) {
                                             @strongify(self);
                                             double changeRange = [value doubleValue] * 100;
                                             // 设置背景色
                                             if (changeRange > 0) {
                                                 self.now.superview.backgroundColor = RGB(204, 21, 21);
                                             }
                                             else if (changeRange < 0) {
                                                 self.now.superview.backgroundColor = RGB(41, 152, 8);
                                             }
//                                             else if (changeRange == 0) {
//                                                 self.now.superview.backgroundColor = RGB(43, 176, 241);
//                                             }
                                             else {
                                                 self.now.superview.backgroundColor = [UIColor clearColor];
                                             }
                                             return [NSString stringWithFormat:@"%.2f%%", changeRange];
                                         }];
    //  现量
    RAC(self.volume, text, @"-") = [[[RACObserve(self.viewModel, VolumeSpread) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
                                    map:^id(id value) {
                                        return [NSString stringWithFormat:@"%d", [value unsignedIntValue] / 100];
                                    }];
    //  总市值（亿）
    RAC(self.ttlAmount, text, @"-") = [[[RACObserve(self.viewModel, TtlAmount) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
                                       map:^id(id value) {
                                           return [NSString stringWithFormat:@"%.0f亿", [value doubleValue]];
                                       }];
    //  市盈率
    RAC(self.pettm, text, @"-") = [[[RACObserve(self.viewModel, PEttm) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
                                   map:^id(id value) {
                                       return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
                                   }];
    //  新闻事件评级
    [[[RACObserve(self.viewModel, NewsRatingLevel) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
     subscribeNext:^(id value) {
         @strongify(self);
         int level = [value intValue];
         switch (level) {
             case 2:
                 self.level.text = @"正+";
                 self.level.superview.backgroundColor = RGB(204, 21, 21);
                 break;
             case 1:
                 self.level.text = @"正";
                 self.level.superview.backgroundColor = RGB(204, 21, 21);
                 break;
             case 0:
                 self.level.text = @"中";
                 self.level.superview.backgroundColor = RGB(43, 176, 241);
                 break;
             case -1:
                 self.level.text = @"负";
                 self.level.superview.backgroundColor = RGB(41, 152, 8);
                 break;
             case -2:
                 self.level.text = @"负-";
                 self.level.superview.backgroundColor = RGB(41, 152, 8);
                 break;
             default:
                 break;
         }
     }];
    //  新闻事件分类
    [[[RACObserve(self.viewModel, NewsRatingName) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
     subscribeNext:^(id value) {
         @strongify(self);
         NSString *label = @"";
         NSRange range = [value rangeOfString:@" | "];
         if (range.length > 0) {
             label = [value substringToIndex:range.location];
         }
         else {
             label = value;
         }
         self.label.text = label;
     }];
    //  新闻事件日期
    [[[RACObserve(self.viewModel, NewsRatingDate) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal]
     subscribeNext:^(NSString *value) {
         @strongify(self);
         int date = [value intValue];
         if (date != 0) {
             NSMutableString *date =[NSMutableString stringWithFormat:@"%@", value];
             [date insertString:@"-" atIndex:4];
             [date insertString:@"-" atIndex:7];
             self.date.text = date;
         }
         else {
             self.date.text = @"—";
         }
     }];
}

- (void)addTrendViewWithCode:(NSString *)code {
    for (UIView *subView in self.trendView.subviews) {
        [subView removeFromSuperview];
    }
    LiteTrendView *trend = [[LiteTrendView alloc] initWithFrame:self.trendView.bounds andCode:code];
    [self.trendView addSubview:trend];
}

- (void)addKLineViewWithCode:(NSString *)code {
    for (UIView *subView in self.kLineView.subviews) {
        [subView removeFromSuperview];
    }
//    KLineViewModel *viewModel = [self.viewModel getKLineViewModel];
//    LiteKLineView *kLine = [[LiteKLineView alloc] initWithFrame:self.kLineView.bounds andViewModel:viewModel];
//    [self.kLineView addSubview:kLine];
}

- (void)dealloc {
    //    NSLog(@"StkQuoteViewCell dealloc (%@)", self.viewModel.Code);
}

@end
