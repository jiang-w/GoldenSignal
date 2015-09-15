//
//  StkScalarView.m
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StkScalarView.h"
#import "StkScalarViewModel.h"

#import <ReactiveCocoa.h>

@interface StkScalarView()

@property(nonatomic, weak) IBOutlet UILabel *prevClose;
@property(nonatomic, weak) IBOutlet UILabel *open;
@property(nonatomic, weak) IBOutlet UILabel *high;
@property(nonatomic, weak) IBOutlet UILabel *low;
@property(nonatomic, weak) IBOutlet UILabel *now;
@property(nonatomic, weak) IBOutlet UILabel *change;
@property(nonatomic, weak) IBOutlet UILabel *changeRange;
@property(nonatomic, weak) IBOutlet UILabel *volumeSpread;
@property(nonatomic, weak) IBOutlet UILabel *volume;
@property(nonatomic, weak) IBOutlet UILabel *changeHandsRate;
@property(nonatomic, weak) IBOutlet UILabel *volRatio;
@property(nonatomic, weak) IBOutlet UILabel *amount;
@property(nonatomic, weak) IBOutlet UILabel *ttlAst;
@property(nonatomic, weak) IBOutlet UILabel *ttlAmountNtlc;
@property(nonatomic, weak) IBOutlet UILabel *PEttm;
@property(nonatomic, weak) IBOutlet UILabel *Eps;
@property(nonatomic, weak) IBOutlet UIButton *favoriteButton;

@property(nonatomic, strong) StkScalarViewModel *viewModel;

@end

@implementation StkScalarView

+ (StkScalarView *)createView {
    return [[[NSBundle mainBundle] loadNibNamed:@"StkScalarView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0"] forState:UIControlStateNormal];
    
    @weakify(self);
    [[self.favoriteButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton *btn) {
         @strongify(self);
         btn.selected = !btn.selected;
         BDStockPool *pool = [BDStockPool sharedInstance];
         if (btn.selected) {
             [pool addStockWithCode:self.viewModel.Code];
         }
         else {
             [pool removeStockWithCode:self.viewModel.Code];
         }
     }];
}

- (void)subscribeDataWithSecuCode:(NSString *)code {
    if (code && ![code isEqualToString:self.viewModel.Code]) {
        self.viewModel = [[StkScalarViewModel alloc] initWithCode:code];
        [self dataBinding];
    }
}

- (void)dataBinding {
    @weakify(self);
    // 昨收价
    RAC(self.prevClose, text, @"-") = [[RACObserve(self.viewModel, PrevClose) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    // 开盘价
    RAC(self.open, text, @"-") = [[RACObserve(self.viewModel, Open) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    RAC(self.open, textColor) = [[RACSignal combineLatest:@[RACObserve(self.viewModel, PrevClose), RACObserve(self.viewModel, Open)]
                                                   reduce:^id(NSNumber *prevClose, NSNumber *open) {
                                                       @strongify(self);
                                                       return [self textColorValue:[open doubleValue] otherValue:[prevClose doubleValue]];
                                                   }] deliverOnMainThread];
    // 当前价
    RAC(self.now, text, @"-") = [[RACObserve(self.viewModel, Now) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    RAC(self.now, textColor) = [[RACSignal combineLatest:@[RACObserve(self.viewModel, PrevClose), RACObserve(self.viewModel, Now)]
                                                  reduce:^id(NSNumber *prevClose, NSNumber *now) {
                                                      @strongify(self);
                                                      return [self textColorValue:[now doubleValue] otherValue:[prevClose doubleValue]];
                                                  }] deliverOnMainThread];
    // 涨跌
    [[[RACSignal combineLatest:@[RACObserve(self.viewModel, PrevClose), RACObserve(self.viewModel, Now)]
                        reduce:^id(NSNumber *prevClose, NSNumber *now) {
                            return @([now doubleValue] - [prevClose doubleValue]);
                        }] deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self);
         self.change.text = [NSString stringWithFormat:@"%.2f", [x doubleValue]];
         self.change.textColor = [self textColorValue:[x doubleValue] otherValue:0];
     }];
    // 涨跌幅
    [[[RACSignal combineLatest:@[RACObserve(self.viewModel, PrevClose), RACObserve(self.viewModel, Now)]
                        reduce:^id(NSNumber *prevClose, NSNumber *now) {
                            return @(([now doubleValue] - [prevClose doubleValue]) / [prevClose doubleValue] * 100);
                        }] deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self);
         self.changeRange.text = [NSString stringWithFormat:@"%.2f%%", [x doubleValue]];
         self.changeRange.textColor = [self textColorValue:[x doubleValue] otherValue:0];
     }];
    // 最高价
    RAC(self.high, text, @"-") = [[RACObserve(self.viewModel, High) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    // 最低价
    RAC(self.low, text, @"-") = [[RACObserve(self.viewModel, Low) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    // 现手
    RAC(self.volumeSpread, text, @"-") = [[RACObserve(self.viewModel, VolumeSpread) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%u", [value unsignedIntValue] / 100];
    }];
    // 成交量(总手)
    RAC(self.volume, text, @"-") = [[RACObserve(self.viewModel, Volume) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f万手", [value unsignedIntValue] / 1000000.0];
    }];
    // 换手率
    RAC(self.changeHandsRate, text, @"-") = [[RACObserve(self.viewModel, ChangeHandsRate) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f%%", [value doubleValue] * 100];
    }];
    // 量比
    RAC(self.volRatio, text, @"-") = [[RACObserve(self.viewModel, VolRatio) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    // 交易额
    RAC(self.amount, text, @"-") = [[RACObserve(self.viewModel, Amount) deliverOnMainThread] map:^id(id value) {
        if ([value doubleValue] > 100000000) {
            return [NSString stringWithFormat:@"%.2f亿", [value doubleValue] / 100000000];
        }
        else {
            return [NSString stringWithFormat:@"%.2f万", [value doubleValue] / 10000];
        }
    }];
    // 总市值
    RAC(self.ttlAst, text, @"-") = [[RACObserve(self.viewModel, TtlAmount) deliverOnMainThread] map:^id(id value) {
        return [value doubleValue] != 0 ? [NSString stringWithFormat:@"%.0f亿", [value doubleValue]] : @"—";
    }];
    // 流通市值
    RAC(self.ttlAmountNtlc, text, @"-") = [[RACObserve(self.viewModel, TtlAmountNtlc) deliverOnMainThread] map:^id(id value) {
        return [value doubleValue] != 0 ? [NSString stringWithFormat:@"%.0f亿", [value doubleValue]] : @"—";
    }];
    // 市盈率
    RAC(self.PEttm, text, @"-") = [[RACObserve(self.viewModel, PEttm) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    // EPS
    RAC(self.Eps, text, @"-") = [[RACObserve(self.viewModel, Eps) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }];
    
    RAC(self.favoriteButton, selected) = [[RACObserve(self.viewModel, Code) deliverOnMainThread] map:^id(id value) {
        @strongify(self);
        BOOL favorited = [[BDStockPool sharedInstance] containStockWithCode:self.viewModel.Code];
        return @(favorited);
    }];
}

- (UIColor *)textColorValue:(double)val1 otherValue:(double)val2 {
    if (val1 > val2) {
        return [UIColor redColor];
    }
    else if (val1 < val2) {
        return [UIColor greenColor];
    }
    else {
        return [UIColor whiteColor];
    }
}

- (void)dealloc {
//    NSLog(@"StkScalarView dealloc (%@)", self.viewModel.Code);
}

@end
