//
//  IdxQuoteView.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxQuoteView.h"
#import "IdxQuoteViewModel.h"
#import <FBKVOController.h>

@implementation IdxQuoteView
{
    IdxQuoteViewModel *_viewModel;
    FBKVOController *_kvo;
}

+ (IdxQuoteView *)createView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"IdxQuoteView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib {
    [self initData];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0"] forState:UIControlStateNormal];
    _kvo = [FBKVOController controllerWithObserver:self];
}

- (void)subscribeIndicatorsWithCode:(NSString *)code {
    if (_viewModel == nil) {
        _viewModel = [[IdxQuoteViewModel alloc] init];
        [self kvoController];
    }
    [_viewModel subscribeQuotationScalarWithCode:code];
    
    if ([[BDStockPool sharedInstance] containStockWithCode:code]) {
        [self.favoriteButton setSelected:YES];
    }
    else {
        [self.favoriteButton setSelected:NO];
    }
}

- (void)initData {
    self.now.text = @"-";
    self.open.text = @"-";
    self.prevClose.text = @"-";
    self.change.text = @"-";
    self.changeRange.text = @"-";
    self.amplitude.text = @"-";
    self.high.text = @"-";
    self.low.text = @"-";
    self.amount.text = @"-";
    self.volume.text = @"-";
    self.volumeSpread.text = @"-";
    self.upCount.text = @"-";
    self.downCount.text = @"-";
}

- (void)kvoController {
    if (_viewModel) {
        [_kvo observe:_viewModel keyPath:@"Open" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.open.text = [NSString stringWithFormat:@"%.2f",model.Open];
                view.open.textColor = [self textColorValue:model.Open otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"PrevClose" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.prevClose.text = [NSString stringWithFormat:@"%.2f",model.PrevClose];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Now" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.now.text = [NSString stringWithFormat:@"%.2f", model.Now];
                view.now.textColor = [view textColorValue:model.Now otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Change" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.change.text = [NSString stringWithFormat:@"%.2f", model.Change];
                view.change.textColor = [view textColorValue:model.Change otherValue:0];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"ChangeRange" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat changeRange = model.ChangeRange * 100.0;
                view.changeRange.text = [NSString stringWithFormat:@"%.2f%%", changeRange];
                view.changeRange.textColor = [view textColorValue:changeRange otherValue:0];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Amplitude" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat amplitude = model.Amplitude * 100.0;
                view.changeRange.text = [NSString stringWithFormat:@"%.2f%%", amplitude];
                view.changeRange.textColor = [view textColorValue:amplitude otherValue:0];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"High" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.high.text = [NSString stringWithFormat:@"%.2f",model.High];
                view.high.textColor = [view textColorValue:model.High otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Low" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.low.text = [NSString stringWithFormat:@"%.2f",model.Low];
                view.low.textColor = [view textColorValue:model.Low otherValue:model.PrevClose];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Amount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.Amount > 100000000) {
                    view.amount.text = [NSString stringWithFormat:@"%.2f亿", model.Amount / 100000000.0];
                }
                else {
                    view.amount.text = [NSString stringWithFormat:@"%.2f万", model.Amount / 10000.0];
                }
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"Volume" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double volume = model.Volume / 1000000.0;
                if (volume > 10000) {
                    view.volume.text = [NSString stringWithFormat:@"%.2f亿", volume / 10000.0];
                }
                else {
                    view.volume.text = [NSString stringWithFormat:@"%.2f万", volume];
                }
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"VolumeSpread" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.volumeSpread.text = [NSString stringWithFormat:@"%ld", model.VolumeSpread / 100];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"UpCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.upCount.text = [NSString stringWithFormat:@"%d", model.UpCount];
            });
        }];
        
        [_kvo observe:_viewModel keyPath:@"DownCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(IdxQuoteView *view, IdxQuoteViewModel *model, NSDictionary *change) {
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
        [pool addStockWithCode:_viewModel.Code];
    }
    else {
        [pool removeStockWithCode:_viewModel.Code];
    }
}

@end