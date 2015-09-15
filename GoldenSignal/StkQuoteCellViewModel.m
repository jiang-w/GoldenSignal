//
//  StkQuoteCellViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "StkQuoteCellViewModel.h"
#import "BDQuotationService.h"

@implementation StkQuoteCellViewModel

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _Code = code;
        [self propertyBinding];
    }
    return self;
}

- (void)propertyBinding {
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:self.Code];
    [self setValue:secu.trdCode forKey:@"TrdCode"];
    [self setValue:secu.name forKey:@"Name"];
    
    BDQuotationService *service = [BDQuotationService sharedInstance];
    RAC(self, PrevClose) = [service scalarSignalWithCode:self.Code andIndicater:@"PrevClose"];
    RAC(self, Now) = [service scalarSignalWithCode:self.Code andIndicater:@"Now"];
    RAC(self, TtlShr) = [service scalarSignalWithCode:self.Code andIndicater:@"TtlShr"];
    RAC(self, VolumeSpread) = [service scalarSignalWithCode:self.Code andIndicater:@"VolumeSpread"];
    RAC(self, PEttm) = [service scalarSignalWithCode:self.Code andIndicater:@"PEttm"];
    RAC(self, NewsRatingDate) = [service scalarSignalWithCode:self.Code andIndicater:@"NewsRatingDate"];
    RAC(self, NewsRatingLevel) = [service scalarSignalWithCode:self.Code andIndicater:@"NewsRatingLevel"];
    RAC(self, NewsRatingName) = [service scalarSignalWithCode:self.Code andIndicater:@"NewsRatingName"];
    RAC(self, TtlAmount) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, TtlShr)] reduce:^id(NSNumber *now, NSNumber *ttlShr){
        return @([now doubleValue] * [ttlShr doubleValue] / 100000000.0);
    }];
    RAC(self, ChangeRange) = [RACSignal combineLatest:@[RACObserve(self, Now), RACObserve(self, PrevClose)] reduce:^id(NSNumber *now, NSNumber *prevClose){
        return @(([now doubleValue] - [prevClose doubleValue]) / [prevClose doubleValue]);
    }];
}

#pragma mark Dealloc

- (void)dealloc {
    //    NSLog(@"StkQuoteCellViewModel dealloc (%@)", self.Code);
}

@end
