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
{
    BDQuotationService *_service;
}

static NSArray *indicaters;

- (id)init {
    self = [super init];
    if (self) {
        _service = [BDQuotationService sharedInstance];
        indicaters = @[@"PrevClose", @"Open", @"Now", @"High", @"Low", @"Amount", @"Volume", @"ChangeHandsRate", @"VolRatio", @"TtlShr", @"TtlShrNtlc", @"VolumeSpread", @"PEttm", @"Eps"];
    }
    return self;
}


//#pragma mark Property kvo
//
//- (double)TtlAmount {
//    return self.Now * self.TtlShr / 100000000.0;
//}
//
//- (double)TtlAmountNtlc {
//    return self.Now * self.TtlShrNtlc / 100000000.0;
//}
//
//// 设置依赖键(kvo)
//+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
//{
//    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
//    NSArray * moreKeyPaths = nil;
//    
//    if ([key isEqualToString:@"TtlAmount"]) {
//        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.TtlShr", nil];
//    }
//    
//    if ([key isEqualToString:@"TtlAmountNtlc"]) {
//        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.TtlShrNtlc", nil];
//    }
//    
//    if (moreKeyPaths) {
//        keyPaths = [keyPaths setByAddingObjectsFromArray:moreKeyPaths];
//    }
//    return keyPaths;
//}


#pragma mark Subscribe

- (void)subscribeQuotationScalarWithCode:(NSString *)code {    
    if (code != nil && ![code isEqualToString:self.Code]) {
        if (self.Code != nil) {
            [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
        }
        // Properties Binding
        [self setValue:code forKey:@"Code"];
        RAC(self, PrevClose) = [_service scalarSignalWithCode:code andIndicater:@"PrevClose"];
        RAC(self, Open) = [_service scalarSignalWithCode:code andIndicater:@"Open"];
        RAC(self, Now) = [_service scalarSignalWithCode:code andIndicater:@"Now"];
        RAC(self, High) = [_service scalarSignalWithCode:code andIndicater:@"High"];
        RAC(self, Low) = [_service scalarSignalWithCode:code andIndicater:@"Low"];
        RAC(self, Amount) = [_service scalarSignalWithCode:code andIndicater:@"Amount"];
        RAC(self, Volume) = [_service scalarSignalWithCode:code andIndicater:@"Volume"];
        RAC(self, ChangeHandsRate) = [_service scalarSignalWithCode:code andIndicater:@"ChangeHandsRate"];
        RAC(self, VolRatio) = [_service scalarSignalWithCode:code andIndicater:@"VolRatio"];
        RAC(self, TtlShr) = [_service scalarSignalWithCode:code andIndicater:@"TtlShr"];
        RAC(self, TtlShrNtlc) = [_service scalarSignalWithCode:code andIndicater:@"TtlShrNtlc"];
        RAC(self, VolumeSpread) = [_service scalarSignalWithCode:code andIndicater:@"VolumeSpread"];
        RAC(self, PEttm) = [_service scalarSignalWithCode:code andIndicater:@"PEttm"];
        RAC(self, Eps) = [_service scalarSignalWithCode:code andIndicater:@"Eps"];
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
    [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
//    NSLog(@"StkScalarViewModel dealloc (%@)", self.Code);
}

@end
