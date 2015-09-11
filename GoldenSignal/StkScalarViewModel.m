//
//  StkScalarViewModel.m
//  GoldenSignal
//
//  Created by Frank on 14/10/27.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StkScalarViewModel.h"
#import "BDQuotationService.h"

@implementation StkScalarViewModel

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _Code = code;
        [self propertyBinding];
    }
    return self;
}

- (void)propertyBinding {
    BDQuotationService *service = [BDQuotationService sharedInstance];
    RAC(self, PrevClose) = [service scalarSignalWithCode:self.Code andIndicater:@"PrevClose"];
    RAC(self, Open) = [service scalarSignalWithCode:self.Code andIndicater:@"Open"];
    RAC(self, Now) = [service scalarSignalWithCode:self.Code andIndicater:@"Now"];
    RAC(self, High) = [service scalarSignalWithCode:self.Code andIndicater:@"High"];
    RAC(self, Low) = [service scalarSignalWithCode:self.Code andIndicater:@"Low"];
    RAC(self, Amount) = [service scalarSignalWithCode:self.Code andIndicater:@"Amount"];
    RAC(self, Volume) = [service scalarSignalWithCode:self.Code andIndicater:@"Volume"];
    RAC(self, ChangeHandsRate) = [service scalarSignalWithCode:self.Code andIndicater:@"ChangeHandsRate"];
    RAC(self, VolRatio) = [service scalarSignalWithCode:self.Code andIndicater:@"VolRatio"];
    RAC(self, TtlShr) = [service scalarSignalWithCode:self.Code andIndicater:@"TtlShr"];
    RAC(self, TtlShrNtlc) = [service scalarSignalWithCode:self.Code andIndicater:@"TtlShrNtlc"];
    RAC(self, VolumeSpread) = [service scalarSignalWithCode:self.Code andIndicater:@"VolumeSpread"];
    RAC(self, PEttm) = [service scalarSignalWithCode:self.Code andIndicater:@"PEttm"];
    RAC(self, Eps) = [service scalarSignalWithCode:self.Code andIndicater:@"Eps"];
    RAC(self, TtlAmount) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, TtlShr)] reduce:^id(NSNumber *now, NSNumber *ttlShr){
        return @([now doubleValue] * [ttlShr doubleValue] / 100000000.0);
    }];
    RAC(self, TtlAmountNtlc) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, TtlShrNtlc)] reduce:^id(NSNumber *now, NSNumber *ttlShrNtlc){
        return @([now doubleValue] * [ttlShrNtlc doubleValue] / 100000000.0);
    }];
}

- (void)dealloc {
//    NSLog(@"StkScalarViewModel dealloc (%@)", self.Code);
}

@end
