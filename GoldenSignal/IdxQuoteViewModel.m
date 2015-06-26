//
//  IdxQuoteViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxQuoteViewModel.h"
#import "BDQuotationService.h"

@implementation IdxQuoteViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
}

static NSArray *indicaters;

- (id)init {
    self = [super init];
    if (self) {
        _propertyUpdateQueue = dispatch_queue_create("IndicatorUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        indicaters = @[@"PrevClose", @"Open", @"Now", @"High", @"Low", @"Amount", @"Volume", @"Change", @"ChangeRange", @"Amplitude", @"VolumeSpread", @"UpCount", @"DownCount"];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}

#pragma mark Subscribe

- (void)subscribeQuotationScalarWithCode:(NSString *)code {
    if (code != nil && ![code isEqualToString:self.Code]) {
        if (self.Code != nil) {
            [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
        }
        [self initPropertyWithCode:code];
        [_service subscribeScalarWithCode:code indicaters:indicaters];
    }
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if ([code isEqualToString: self.Code] && [indicaters containsObject:indicateName]) {
        dispatch_async(_propertyUpdateQueue, ^{
            [self setValue:value forKey:indicateName];
        });
    }
}

- (void)initPropertyWithCode:(NSString *)code {
    [self setValue:code forKey:@"Code"];
    float prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] floatValue];
    [self setValue:[NSNumber numberWithFloat:prevClose] forKey:@"PrevClose"];
    float open = [[_service getCurrentIndicateWithCode:code andName:@"Open"] floatValue];
    [self setValue:[NSNumber numberWithFloat:open] forKey:@"Open"];
    float now = [[_service getCurrentIndicateWithCode:code andName:@"Now"] floatValue];
    [self setValue:[NSNumber numberWithFloat:now] forKey:@"Now"];
    float high = [[_service getCurrentIndicateWithCode:code andName:@"High"] floatValue];
    [self setValue:[NSNumber numberWithFloat:high] forKey:@"High"];
    float low = [[_service getCurrentIndicateWithCode:code andName:@"Low"] floatValue];
    [self setValue:[NSNumber numberWithFloat:low] forKey:@"Low"];
    float amount = [[_service getCurrentIndicateWithCode:code andName:@"Amount"] floatValue];
    [self setValue:[NSNumber numberWithFloat:amount] forKey:@"Amount"];
    int volume = [[_service getCurrentIndicateWithCode:code andName:@"Volume"] intValue];
    [self setValue:[NSNumber numberWithInt:volume] forKey:@"Volume"];
    float change = [[_service getCurrentIndicateWithCode:code andName:@"Change"] floatValue];
    [self setValue:[NSNumber numberWithFloat:change] forKey:@"Change"];
    float changeRange = [[_service getCurrentIndicateWithCode:code andName:@"ChangeRange"] floatValue];
    [self setValue:[NSNumber numberWithFloat:changeRange] forKey:@"ChangeRange"];
    float amplitude = [[_service getCurrentIndicateWithCode:code andName:@"Amplitude"] floatValue];
    [self setValue:[NSNumber numberWithFloat:amplitude] forKey:@"Amplitude"];
    int volumeSpread = [[_service getCurrentIndicateWithCode:code andName:@"VolumeSpread"] intValue];
    [self setValue:[NSNumber numberWithInt:volumeSpread] forKey:@"VolumeSpread"];
    int upCount = [[_service getCurrentIndicateWithCode:code andName:@"UpCount"] intValue];
    [self setValue:[NSNumber numberWithInt:upCount] forKey:@"UpCount"];
    int downCount = [[_service getCurrentIndicateWithCode:code andName:@"DownCount"] intValue];
    [self setValue:[NSNumber numberWithInt:downCount] forKey:@"DownCount"];
}


#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
    NSLog(@"%@ IdxQuoteViewModel dealloc", self.Code);
}

@end