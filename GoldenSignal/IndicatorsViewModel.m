//
//  BDQuotation.m
//  CBNAPP
//
//  Created by Frank on 14/10/27.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "IndicatorsViewModel.h"
#import "BDQuotationService.h"

@implementation IndicatorsViewModel
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
        indicaters = @[@"PrevClose", @"Open", @"Now", @"High", @"Low", @"Amount", @"Volume", @"Change", @"ChangeRange", @"ChangeHandsRate", @"VolRatio", @"TtlShr", @"TtlShrNtlc", @"VolumeSpread", @"PEttm", @"Eps"];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}


#pragma mark Property kvo

- (float)TtlAmount {
    return self.Now * self.TtlShr / 100000000.0;
}

- (float)TtlAmountNtlc {
    return self.Now * self.TtlShrNtlc / 100000000.0;
}

// 设置依赖键(kvo)
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    
    if ([key isEqualToString:@"TtlAmount"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.TtlShr", nil];
    }
    
    if ([key isEqualToString:@"TtlAmountNtlc"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.TtlShrNtlc", nil];
    }
    
    if (moreKeyPaths) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:moreKeyPaths];
    }
    return keyPaths;
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
    float changeHandsRate = [[_service getCurrentIndicateWithCode:code andName:@"ChangeHandsRate"] floatValue];
    [self setValue:[NSNumber numberWithFloat:changeHandsRate] forKey:@"ChangeHandsRate"];
    float volRatio = [[_service getCurrentIndicateWithCode:code andName:@"VolRatio"] floatValue];
    [self setValue:[NSNumber numberWithFloat:volRatio] forKey:@"VolRatio"];
    float ttlShr = [[_service getCurrentIndicateWithCode:code andName:@"TtlShr"] floatValue];
    [self setValue:[NSNumber numberWithFloat:ttlShr] forKey:@"TtlShr"];
    float ttlShrNtlc = [[_service getCurrentIndicateWithCode:code andName:@"TtlShrNtlc"] floatValue];
    [self setValue:[NSNumber numberWithFloat:ttlShrNtlc] forKey:@"TtlShrNtlc"];
    int volumeSpread = [[_service getCurrentIndicateWithCode:code andName:@"VolumeSpread"] intValue];
    [self setValue:[NSNumber numberWithInt:volumeSpread] forKey:@"VolumeSpread"];
    float peTtm = [[_service getCurrentIndicateWithCode:code andName:@"PEttm"] floatValue];
    [self setValue:[NSNumber numberWithFloat:peTtm] forKey:@"PEttm"];
    float eps = [[_service getCurrentIndicateWithCode:code andName:@"EpsTtm"] floatValue];
    [self setValue:[NSNumber numberWithFloat:eps] forKey:@"Eps"];
}


#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
    NSLog(@"%@ Indicators dealloc", self.Code);
}

@end
