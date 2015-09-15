//
//  IdxScalarViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxScalarViewModel.h"
#import "BDQuotationService.h"


@implementation IdxScalarViewModel

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        [self setValue:code forKey:@"Code"];
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
    RAC(self, Amplitude) = [service scalarSignalWithCode:self.Code andIndicater:@"Amplitude"];
    RAC(self, VolumeSpread) = [service scalarSignalWithCode:self.Code andIndicater:@"VolumeSpread"];
    RAC(self, UpCount) = [service scalarSignalWithCode:self.Code andIndicater:@"UpCount"];
    RAC(self, DownCount) = [service scalarSignalWithCode:self.Code andIndicater:@"DownCount"];
    RAC(self, Change) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, PrevClose)] reduce:^id(NSNumber *now, NSNumber *prevClose){
        return @([now doubleValue] - [prevClose doubleValue]);
    }];
    RAC(self, ChangeRange) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, PrevClose)] reduce:^id(NSNumber *now, NSNumber *prevClose){
        return @(([now doubleValue] - [prevClose doubleValue]) / [prevClose doubleValue]);
    }];
}


- (void)dealloc {
//    NSLog(@"IdxScalarViewModel dealloc (%@)", self.Code);
}

@end
