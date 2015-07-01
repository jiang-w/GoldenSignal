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

- (double)TtlAmount {
    return self.Now * self.TtlShr / 100000000.0;
}

- (double)TtlAmountNtlc {
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
    double prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:prevClose] forKey:@"PrevClose"];
    double open = [[_service getCurrentIndicateWithCode:code andName:@"Open"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:open] forKey:@"Open"];
    double now = [[_service getCurrentIndicateWithCode:code andName:@"Now"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:now] forKey:@"Now"];
    double high = [[_service getCurrentIndicateWithCode:code andName:@"High"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:high] forKey:@"High"];
    double low = [[_service getCurrentIndicateWithCode:code andName:@"Low"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:low] forKey:@"Low"];
    double amount = [[_service getCurrentIndicateWithCode:code andName:@"Amount"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:amount] forKey:@"Amount"];
    unsigned long volume = [[_service getCurrentIndicateWithCode:code andName:@"Volume"] unsignedLongValue];
    [self setValue:[NSNumber numberWithUnsignedLong:volume] forKey:@"Volume"];
    double change = [[_service getCurrentIndicateWithCode:code andName:@"Change"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:change] forKey:@"Change"];
    double changeRange = [[_service getCurrentIndicateWithCode:code andName:@"ChangeRange"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:changeRange] forKey:@"ChangeRange"];
    double changeHandsRate = [[_service getCurrentIndicateWithCode:code andName:@"ChangeHandsRate"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:changeHandsRate] forKey:@"ChangeHandsRate"];
    double volRatio = [[_service getCurrentIndicateWithCode:code andName:@"VolRatio"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:volRatio] forKey:@"VolRatio"];
    double ttlShr = [[_service getCurrentIndicateWithCode:code andName:@"TtlShr"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:ttlShr] forKey:@"TtlShr"];
    double ttlShrNtlc = [[_service getCurrentIndicateWithCode:code andName:@"TtlShrNtlc"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:ttlShrNtlc] forKey:@"TtlShrNtlc"];
    unsigned long volumeSpread = [[_service getCurrentIndicateWithCode:code andName:@"VolumeSpread"] unsignedLongValue];
    [self setValue:[NSNumber numberWithUnsignedLong:volumeSpread] forKey:@"VolumeSpread"];
    double peTtm = [[_service getCurrentIndicateWithCode:code andName:@"PEttm"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:peTtm] forKey:@"PEttm"];
    double eps = [[_service getCurrentIndicateWithCode:code andName:@"EpsTtm"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:eps] forKey:@"Eps"];
}


#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
    NSLog(@"%@ Indicators dealloc", self.Code);
}

@end
