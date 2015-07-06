//
//  IdxQuoteView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxScalarView.h"
#import "IdxScalarViewModel.h"
#import <FBKVOController.h>

@implementation IdxScalarView
{
    IdxScalarViewModel *_vm;
    FBKVOController *_kvo;
}

+ (IdxScalarView *)createView {
    return [[[NSBundle mainBundle] loadNibNamed:@"IdxScalarView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [self initData];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0"] forState:UIControlStateNormal];
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (void)loadDataWithIdxCode:(NSString *)code {
    if (_vm == nil) {
        _vm = [[IdxScalarViewModel alloc] init];
        [self kvoController];
    }
    [_vm loadDataWithCode:code];
    
    if ([[BDStockPool sharedInstance] containStockWithCode:code]) {
        [self.favoriteButton setSelected:YES];
    }
    else {
        [self.favoriteButton setSelected:NO];
    }
}

- (void)initData {
    self.now.text = @"—";
    self.open.text = @"—";
    self.prevClose.text = @"—";
    self.change.text = @"—";
    self.changeRange.text = @"—";
    self.amplitude.text = @"—";
    self.high.text = @"—";
    self.low.text = @"—";
    self.amount.text = @"—";
    self.volume.text = @"—";
    self.volumeSpread.text = @"—";
    self.upCount.text = @"—";
    self.downCount.text = @"—";
}

- (void)kvoController {
    if (_vm) {
        [_kvo observe:_vm keyPath:@"Open" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.open.text = [NSString stringWithFormat:@"%.2f",model.Open];
                view.open.textColor = [view textColorValue:model.Open otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"PrevClose" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.prevClose.text = [NSString stringWithFormat:@"%.2f",model.PrevClose];
            });
        }];

        [_kvo observe:_vm keyPath:@"Now" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.now.text = [NSString stringWithFormat:@"%.2f", model.Now];
                view.now.textColor = [view textColorValue:model.Now otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Change" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.change.text = [NSString stringWithFormat:@"%.2f", model.Change];
                view.change.textColor = [view textColorValue:model.Change otherValue:0];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"ChangeRange" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double changeRange = model.ChangeRange * 100.0;
                view.changeRange.text = isnan(changeRange) ? @"0.00%" : [NSString stringWithFormat:@"%.2f%%", changeRange];
                view.changeRange.textColor = [view textColorValue:changeRange otherValue:0];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Amplitude" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double amplitude = model.Amplitude * 100.0;
                view.amplitude.text = [NSString stringWithFormat:@"%.2f%%", amplitude];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"High" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.high.text = [NSString stringWithFormat:@"%.2f",model.High];
                view.high.textColor = [view textColorValue:model.High otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Low" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.low.text = [NSString stringWithFormat:@"%.2f",model.Low];
                view.low.textColor = [view textColorValue:model.Low otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Amount" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double amount = model.Amount / 10000;
                if (model.Amount > 10000) {
                    view.amount.text = [NSString stringWithFormat:@"%.0f亿", amount / 10000];
                }
                else {
                    view.amount.text = [NSString stringWithFormat:@"%.0f万", amount];
                }
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Volume" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double volume = model.Volume / 1000000.0;
                if (volume >= 10000) {
                    view.volume.text = [NSString stringWithFormat:@"%.3f亿", volume / 10000];
                }
                else {
                    view.volume.text = [NSString stringWithFormat:@"%.0f万", volume];
                }
            });
        }];
        
        [_kvo observe:_vm keyPath:@"VolumeSpread" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                unsigned long volume = model.VolumeSpread / 100;
                if (volume > 10000) {
                    view.volumeSpread.text = [NSString stringWithFormat:@"%.2f万", volume / 10000.0];
                }
                else {
                    view.volumeSpread.text = [NSString stringWithFormat:@"%ld", volume];
                }
            });
        }];
        
        [_kvo observe:_vm keyPath:@"UpCount" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.upCount.text = [NSString stringWithFormat:@"%d", model.UpCount];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"DownCount" options:NSKeyValueObservingOptionNew block:^(IdxScalarView *view, IdxScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.downCount.text = [NSString stringWithFormat:@"%d", model.DownCount];
            });
        }];
    }
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
        [pool addStockWithCode:_vm.Code];
    }
    else {
        [pool removeStockWithCode:_vm.Code];
    }
}

- (void)dealloc {
//    NSLog(@"IdxQuoteView dealloc (%@)", _viewModel.Code);
}

@end
