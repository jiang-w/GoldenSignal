//
//  StkScalarView.m
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StkScalarView.h"
#import "StkScalarViewModel.h"
#import <FBKVOController.h>

@implementation StkScalarView
{
    StkScalarViewModel *_vm;
    FBKVOController *_kvo;
}

+ (StkScalarView *)createView {
    return [[[NSBundle mainBundle] loadNibNamed:@"StkScalarView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0"] forState:UIControlStateNormal];
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (NSString *)code {
    if (_vm) {
        return _vm.Code;
    }
    else {
        return nil;
    }
}

- (void)loadDataWithCode:(NSString *)code {
    if (_vm == nil) {
        _vm = [[StkScalarViewModel alloc] init];
        [self kvoController];
    }
    [_vm subscribeQuotationScalarWithCode:code];
    
    if ([[BDStockPool sharedInstance] containStockWithCode:code]) {
        [self.favoriteButton setSelected:YES];
    }
    else {
        [self.favoriteButton setSelected:NO];
    }
}

- (void)kvoController {
    if (_vm) {
        [_kvo observe:_vm keyPath:@"Open" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.open.text = [NSString stringWithFormat:@"%.2f",model.Open];
                view.open.textColor = [view textColorValue:model.Open otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"PrevClose" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.prevClose.text = [NSString stringWithFormat:@"%.2f",model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.now.text = [NSString stringWithFormat:@"%.2f", model.Now];
                view.now.textColor = [view textColorValue:model.Now otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Change" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.change.text = [NSString stringWithFormat:@"%.2f", model.Change];
                view.change.textColor = [view textColorValue:model.Change otherValue:0];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double changeRange = model.ChangeRange * 100.0;
                view.changeRange.text = [NSString stringWithFormat:@"%.2f%%", changeRange];
                view.changeRange.textColor = [view textColorValue:changeRange otherValue:0];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"High" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.high.text = [NSString stringWithFormat:@"%.2f",model.High];
                view.high.textColor = [view textColorValue:model.High otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Low" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.low.text = [NSString stringWithFormat:@"%.2f",model.Low];
                view.low.textColor = [view textColorValue:model.Low otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Amount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.Amount > 100000000) {
                    view.amount.text = [NSString stringWithFormat:@"%.2f亿", model.Amount / 100000000];
                }
                else {
                    view.amount.text = [NSString stringWithFormat:@"%.2f万", model.Amount / 10000];
                }
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Volume" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double volume = model.Volume / 1000000.0;
                view.volume.text = [NSString stringWithFormat:@"%.2f万手", volume];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"ChangeHandsRate" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double rate = model.ChangeHandsRate * 100.0;
                view.changeHandsRate.text = [NSString stringWithFormat:@"%.2f%%", rate];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"VolRatio" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.volRatio.text = [NSString stringWithFormat:@"%.2f", model.VolRatio];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"VolumeSpread" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.volumeSpread.text = [NSString stringWithFormat:@"%ld", model.VolumeSpread / 100];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"TtlAmount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.ttlAst.text = model.TtlAmount != 0 ? [NSString stringWithFormat:@"%.0f亿", model.TtlAmount] : @"—";
            });
        }];
        
        [_kvo observe:_vm keyPath:@"TtlAmountNtlc" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.ttlAmountNtlc.text = model.TtlAmountNtlc != 0 ? [NSString stringWithFormat:@"%.0f亿", model.TtlAmountNtlc] : @"—";
            });
        }];
        
        [_kvo observe:_vm keyPath:@"PEttm" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.PEttm.text = [NSString stringWithFormat:@"%.2f", model.PEttm];
            });
        }];
        
        [_kvo observe:_vm keyPath:@"Eps" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(StkScalarView *view, StkScalarViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.Eps.text = [NSString stringWithFormat:@"%.2f", model.Eps];
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
        //NSLog(@"添加自选股:%@", self.code);
        [pool addStockWithCode:self.code];
    }
    else {
        //NSLog(@"移除自选股:%@", self.code);
        [pool removeStockWithCode:self.code];
    }
}

- (void)dealloc {
//    NSLog(@"StkScalarView dealloc (%@)", self.code);
}

@end
