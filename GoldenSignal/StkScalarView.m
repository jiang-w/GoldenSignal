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

@end

@implementation StkScalarView

+ (StkScalarView *)createView {
    return [[[NSBundle mainBundle] loadNibNamed:@"StkScalarView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0"] forState:UIControlStateNormal];
    [self dataBinding];
}

- (void)dataBinding {
    @weakify(self);
    [RACObserve(self, viewModel) subscribeNext:^(StkScalarViewModel *vm) {
        if (vm) {
            @strongify(self);
            // 昨收价
            RACSignal *prevCloseSignal = RACObserve(vm, PrevClose);
            RAC(self.prevClose, text) = [[prevCloseSignal map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            @weakify(self);
            // 开盘价
            RACSignal *openSignal = RACObserve(vm, Open);
            RAC(self.open, text) = [[openSignal map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            RAC(self.open, textColor) = [[RACSignal combineLatest:@[prevCloseSignal, openSignal]
                                                          reduce:^id(NSNumber *prevClose, NSNumber *open) {
                                                              @strongify(self);
                                                              return [self textColorValue:[open doubleValue] otherValue:[prevClose doubleValue]];
                                                          }] deliverOn:RACScheduler.mainThreadScheduler];
            // 当前价
            RACSignal *nowSignal = RACObserve(vm, Now);
            RAC(self.now, text) = [[nowSignal map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            RAC(self.now, textColor) = [[RACSignal combineLatest:@[prevCloseSignal, nowSignal]
                                                         reduce:^id(NSNumber *prevClose, NSNumber *now) {
                                                             @strongify(self);
                                                             return [self textColorValue:[now doubleValue] otherValue:[prevClose doubleValue]];
                                                         }] deliverOn:RACScheduler.mainThreadScheduler];
            // 涨跌
            RACSignal *changeSignal = [RACSignal combineLatest:@[prevCloseSignal, nowSignal]
                                                        reduce:^id(NSNumber *prevClose, NSNumber *now) {
                                                            return @([now doubleValue] - [prevClose doubleValue]);
                                                        }];
            [[changeSignal deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(id x) {
                @strongify(self);
                self.change.text = [NSString stringWithFormat:@"%.2f", [x doubleValue]];
                self.change.textColor = [self textColorValue:[x doubleValue] otherValue:0];
            }];
            // 涨跌幅
            RACSignal *changeRangeSignal = [RACSignal combineLatest:@[prevCloseSignal, nowSignal]
                                                             reduce:^id(NSNumber *prevClose, NSNumber *now) {
                                                                 return @(([now doubleValue] - [prevClose doubleValue]) / [prevClose doubleValue] * 100);
                                                             }];
            [[changeRangeSignal deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(id x) {
                @strongify(self);
                self.changeRange.text = [NSString stringWithFormat:@"%.2f%%", [x doubleValue]];
                self.changeRange.textColor = [self textColorValue:[x doubleValue] otherValue:0];
            }];
            // 最高价
            RAC(self.high, text) = [[RACObserve(vm, High) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 最低价
            RAC(self.low, text) = [[RACObserve(vm, Low) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 现手
            RAC(self.volumeSpread, text) = [[RACObserve(vm, VolumeSpread) map:^id(id value) {
                return [NSString stringWithFormat:@"%u", [value unsignedIntValue] / 100];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 成交量(总手)
            RAC(self.volume, text) = [[RACObserve(vm, Volume) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f万手", [value unsignedIntValue] / 1000000.0];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 换手率
            RAC(self.changeHandsRate, text) = [[RACObserve(vm, ChangeHandsRate) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f%%", [value doubleValue] * 100];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 量比
            RAC(self.volRatio, text) = [[RACObserve(vm, VolRatio) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 交易额
            RAC(self.amount, text) = [[RACObserve(vm, Amount) map:^id(id value) {
                if ([value doubleValue] > 100000000) {
                    return [NSString stringWithFormat:@"%.2f亿", [value doubleValue] / 100000000];
                }
                else {
                    return [NSString stringWithFormat:@"%.2f万", [value doubleValue] / 10000];
                }
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 总市值
            RAC(self.ttlAst, text) = [[RACObserve(vm, TtlAmount) map:^id(id value) {
                return [value doubleValue] != 0 ? [NSString stringWithFormat:@"%.0f亿", [value doubleValue]] : @"—";
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 流通市值
            RAC(self.ttlAmountNtlc, text) = [[RACObserve(vm, TtlAmountNtlc) map:^id(id value) {
                return [value doubleValue] != 0 ? [NSString stringWithFormat:@"%.0f亿", [value doubleValue]] : @"—";
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // 市盈率
            RAC(self.PEttm, text) = [[RACObserve(vm, PEttm) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            // EPS
            RAC(self.Eps, text) = [[RACObserve(vm, Eps) map:^id(id value) {
                return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
            }] deliverOn:RACScheduler.mainThreadScheduler];
            
            RAC(self.favoriteButton, selected) = [[RACObserve(vm, Code) map:^id(id value) {
                @strongify(self);
                BOOL favorited = [[BDStockPool sharedInstance] containStockWithCode:self.viewModel.Code];
                return @(favorited);
            }] deliverOn:RACScheduler.mainThreadScheduler];
        }
    }];
    
    [[self.favoriteButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
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

- (void)loadDataWithCode:(NSString *)code {
    if (self.viewModel == nil) {
        self.viewModel = [[StkScalarViewModel alloc] initWithCode:code];
    }
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
