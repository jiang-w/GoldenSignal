//
//  IdxQuoteView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxScalarView.h"
#import "IdxScalarViewModel.h"

#import <ReactiveCocoa.h>

@interface IdxScalarView()

@property (weak, nonatomic) IBOutlet UILabel *now;
@property (weak, nonatomic) IBOutlet UILabel *change;
@property (weak, nonatomic) IBOutlet UILabel *changeRange;
@property (weak, nonatomic) IBOutlet UILabel *open;
@property (weak, nonatomic) IBOutlet UILabel *prevClose;
@property (weak, nonatomic) IBOutlet UILabel *high;
@property (weak, nonatomic) IBOutlet UILabel *low;
@property (weak, nonatomic) IBOutlet UILabel *volume;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *amplitude;
@property (weak, nonatomic) IBOutlet UILabel *volumeSpread;
@property (weak, nonatomic) IBOutlet UILabel *upCount;
@property (weak, nonatomic) IBOutlet UILabel *downCount;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property(nonatomic, strong) IdxScalarViewModel *viewModel;

@end

@implementation IdxScalarView

+ (IdxScalarView *)createView {
    return [[[NSBundle mainBundle] loadNibNamed:@"IdxScalarView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0"] forState:UIControlStateNormal];
}

- (void)subscribeDataWithSecuCode:(NSString *)code {
    if (code && ![code isEqualToString:self.viewModel.Code]) {
        self.viewModel = [[IdxScalarViewModel alloc] initWithCode:code];
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
        unsigned long volume = [value unsignedIntValue] / 100;
        if (volume > 10000) {
            return [NSString stringWithFormat:@"%.2f万", volume / 10000.0];
        }
        else {
            return [NSString stringWithFormat:@"%ld", volume];
        }
    }];
    // 成交量(总手)
    RAC(self.volume, text, @"-") = [[RACObserve(self.viewModel, Volume) deliverOnMainThread] map:^id(id value) {
        double volume = [value unsignedIntValue] / 1000000.0;
        if (volume >= 10000) {
            return [NSString stringWithFormat:@"%.2f亿", volume / 10000];
        }
        else {
            return [NSString stringWithFormat:@"%.0f万", volume];
        }
    }];
    // 振幅
    RAC(self.amplitude, text, @"-") = [[RACObserve(self.viewModel, Amplitude) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%.2f%%", [value doubleValue] * 100];
    }];
    // 上涨家数
    RAC(self.upCount, text, @"-") = [[RACObserve(self.viewModel, UpCount) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%d", [value intValue]];
    }];
    // 下跌家数
    RAC(self.downCount, text, @"-") = [[RACObserve(self.viewModel, DownCount) deliverOnMainThread] map:^id(id value) {
        return [NSString stringWithFormat:@"%d", [value intValue]];
    }];
    // 交易额
    RAC(self.amount, text, @"-") = [[RACObserve(self.viewModel, Amount) deliverOnMainThread] map:^id(id value) {
        if ([value doubleValue] > 100000000) {
            return [NSString stringWithFormat:@"%.0f亿", [value doubleValue] / 100000000];
        }
        else {
            return [NSString stringWithFormat:@"%.0f万", [value doubleValue] / 10000];
        }
    }];
    
    RAC(self.favoriteButton, selected) = [[RACObserve(self.viewModel, Code) deliverOnMainThread] map:^id(id value) {
        @strongify(self);
        BOOL favorited = [[BDStockPool sharedInstance] containStockWithCode:self.viewModel.Code];
        return @(favorited);
    }];
}

- (UIColor *)textColorValue:(float)val1 otherValue:(float)val2 {
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

- (IBAction)favoriteBtnClick:(id)sender {
    UIButton *favoriteBtn = (UIButton *)sender;
    favoriteBtn.selected = !favoriteBtn.selected;
    BDStockPool *pool = [BDStockPool sharedInstance];
    if (favoriteBtn.selected) {
        [pool addStockWithCode:_viewModel.Code];
    }
    else {
        [pool removeStockWithCode:_viewModel.Code];
    }
}

- (void)dealloc {
//    NSLog(@"IdxScalarView dealloc (%@)", self.viewModel.Code);
}

@end
