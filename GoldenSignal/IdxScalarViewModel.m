//
//  IdxScalarViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxScalarViewModel.h"
#import "BDQuotationService.h"

#define IndicaterNames @[@"PrevClose", @"Open", @"Now", @"High", @"Low", @"Amount", @"Volume", @"Amplitude", @"VolumeSpread", @"UpCount", @"DownCount"]

@implementation IdxScalarViewModel
{
    BDQuotationService *_service;
}

- (id)init {
    self = [super init];
    if (self) {
        _service = [BDQuotationService sharedInstance];
    }
    return self;
}

#pragma mark Subscribe

- (void)loadDataWithCode:(NSString *)code {
    if (code != nil && ![code isEqualToString:self.Code]) {
        if (self.Code) {
            [_service unsubscribeScalarWithCode:self.Code indicaters:IndicaterNames];
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
        RAC(self, Amplitude) = [_service scalarSignalWithCode:code andIndicater:@"Amplitude"];
        RAC(self, VolumeSpread) = [_service scalarSignalWithCode:code andIndicater:@"VolumeSpread"];
        RAC(self, UpCount) = [_service scalarSignalWithCode:code andIndicater:@"UpCount"];
        RAC(self, DownCount) = [_service scalarSignalWithCode:code andIndicater:@"DownCount"];
        RAC(self, Change) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, PrevClose)] reduce:^id(NSNumber *now, NSNumber *prevClose){
            return @([now doubleValue] - [prevClose doubleValue]);
        }];
        RAC(self, ChangeRange) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, PrevClose)] reduce:^id(NSNumber *now, NSNumber *prevClose){
            return @(([now doubleValue] - [prevClose doubleValue]) / [prevClose doubleValue]);
        }];
    }
}

#pragma mark Dealloc

- (void)dealloc {
    [_service unsubscribeScalarWithCode:self.Code indicaters:IndicaterNames];
//    NSLog(@"IdxQuoteViewModel dealloc (%@)", self.Code);
}

@end
