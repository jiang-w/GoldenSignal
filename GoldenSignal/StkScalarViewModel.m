//
//  StkScalarViewModel.m
//  GoldenSignal
//
//  Created by Frank on 14/10/27.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "StkScalarViewModel.h"
#import "BDQuotationService.h"

#define IndicaterNames @[@"PrevClose", @"Open", @"Now", @"High", @"Low", @"Amount", @"Volume", @"ChangeHandsRate", @"VolRatio", @"TtlShr", @"TtlShrNtlc", @"VolumeSpread", @"PEttm", @"Eps"]

@implementation StkScalarViewModel

- (void)subscribeQuotationScalarWithCode:(NSString *)code {
    BDQuotationService *service = [BDQuotationService sharedInstance];
    if (code != nil && ![code isEqualToString:self.Code]) {
        if (self.Code != nil) {
            [service unsubscribeScalarWithCode:self.Code indicaters:IndicaterNames];
        }
        // Properties Binding
        [self setValue:code forKey:@"Code"];
        RAC(self, PrevClose) = [service scalarSignalWithCode:code andIndicater:@"PrevClose"];
        RAC(self, Open) = [service scalarSignalWithCode:code andIndicater:@"Open"];
        RAC(self, Now) = [service scalarSignalWithCode:code andIndicater:@"Now"];
        RAC(self, High) = [service scalarSignalWithCode:code andIndicater:@"High"];
        RAC(self, Low) = [service scalarSignalWithCode:code andIndicater:@"Low"];
        RAC(self, Amount) = [service scalarSignalWithCode:code andIndicater:@"Amount"];
        RAC(self, Volume) = [service scalarSignalWithCode:code andIndicater:@"Volume"];
        RAC(self, ChangeHandsRate) = [service scalarSignalWithCode:code andIndicater:@"ChangeHandsRate"];
        RAC(self, VolRatio) = [service scalarSignalWithCode:code andIndicater:@"VolRatio"];
        RAC(self, TtlShr) = [service scalarSignalWithCode:code andIndicater:@"TtlShr"];
        RAC(self, TtlShrNtlc) = [service scalarSignalWithCode:code andIndicater:@"TtlShrNtlc"];
        RAC(self, VolumeSpread) = [service scalarSignalWithCode:code andIndicater:@"VolumeSpread"];
        RAC(self, PEttm) = [service scalarSignalWithCode:code andIndicater:@"PEttm"];
        RAC(self, Eps) = [service scalarSignalWithCode:code andIndicater:@"Eps"];
        RAC(self, TtlAmount) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, TtlShr)] reduce:^id(NSNumber *now, NSNumber *ttlShr){
            return @([now doubleValue] * [ttlShr doubleValue] / 100000000.0);
        }];
        RAC(self, TtlAmountNtlc) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, TtlShrNtlc)] reduce:^id(NSNumber *now, NSNumber *ttlShrNtlc){
            return @([now doubleValue] * [ttlShrNtlc doubleValue] / 100000000.0);
        }];
    }
}


#pragma mark Dealloc

- (void)dealloc {
    [[BDQuotationService sharedInstance] unsubscribeScalarWithCode:self.Code indicaters:IndicaterNames];
//    NSLog(@"StkScalarViewModel dealloc (%@)", self.Code);
}

@end
