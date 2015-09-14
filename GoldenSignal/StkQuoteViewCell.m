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

- (NSString *)secuCode {
    return self.viewModel.Code;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)subscribeDataWithSecuCode:(NSString *)code {
    if (code && ![code isEqualToString:self.viewModel.Code]) {
        StkQuoteCellViewModel *viewModel = [[StkQuoteCellViewModel alloc] initWithCode:code];
        self.viewModel = viewModel;
        
//        [self addTrendViewWithCode:code];
//        [self addKLineViewWithCode:code];
    }
    
    @weakify(self);
    //  股票名称
    [[[RACObserve(self.viewModel, Name) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         self.name.text = value != nil ? value : @"-";
     }];
    //  交易代码
    [[[RACObserve(self.viewModel, TrdCode) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         self.trdCode.text = value != nil ? value : @"-";
     }];
    //  交易代码
    [[[RACObserve(self.viewModel, Now) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         self.now.text = [value doubleValue] != 0 ? [NSString stringWithFormat:@"%.2f", [value doubleValue]] : @"—";
     }];
    //  涨跌幅
    [[[RACObserve(self.viewModel, ChangeRange) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         double changeRange = [value doubleValue] * 100.0;
         if ([[NSString stringWithFormat:@"%f", changeRange] isEqualToString:@"inf"]
             || [[NSString stringWithFormat:@"%f", changeRange] isEqualToString:@"nan"]) {
             self.changeRange.text = @"—";
         }
         else {
             self.changeRange.text = [NSString stringWithFormat:@"%.2f%%", changeRange];
         }
         // 设置背景色
         if (changeRange > 0) {
             self.now.superview.backgroundColor = RGB(204, 21, 21);
         }
         else if (changeRange < 0) {
             self.now.superview.backgroundColor = RGB(41, 152, 8);
         }
         else if (changeRange == 0) {
             self.now.superview.backgroundColor = RGB(43, 176, 241);
         }
         else {
             self.now.superview.backgroundColor = [UIColor clearColor];
         }
     }];
    //  现量
    [[[RACObserve(self.viewModel, VolumeSpread) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         self.volume.text = [value unsignedIntValue] != 0 ? [NSString stringWithFormat:@"%d", [value unsignedIntValue] / 100] : @"—";
     }];
    //  总市值（亿）
    [[[RACObserve(self.viewModel, TtlAmount) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         self.ttlAmount.text = [value doubleValue] != 0 ? [NSString stringWithFormat:@"%.0f亿", [value doubleValue]] : @"—";
     }];
    //  总市值（亿）
    [[[RACObserve(self.viewModel, PEttm) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
     subscribeNext:^(id value) {
         @strongify(self);
         self.pettm.text = [NSString stringWithFormat:@"%.2f", [value doubleValue]];
     }];
    //  新闻事件评级
    [[[RACObserve(self.viewModel, NewsRatingLevel) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
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
    [[[RACObserve(self.viewModel, NewsRatingName) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
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
    [[[RACObserve(self.viewModel, NewsRatingDate) takeUntil:self.rac_prepareForReuseSignal] deliverOnMainThread]
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
    KLineViewModel *viewModel = [self.viewModel getKLineViewModel];
    LiteKLineView *kLine = [[LiteKLineView alloc] initWithFrame:self.kLineView.bounds andViewModel:viewModel];
    [self.kLineView addSubview:kLine];
}

- (void)dealloc {
//    NSLog(@"StkQuoteViewCell dealloc (%@)", self.viewModel.Code);
}

@end
