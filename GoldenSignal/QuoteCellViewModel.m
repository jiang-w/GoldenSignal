//
//  QuoteCellViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteCellViewModel.h"
#import "BDQuotationService.h"

@implementation QuoteCellViewModel
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
        indicaters = @[@"Name", @"Now", @"PrevClose", @"VolumeSpread", @"TtlShr", @"PEttm", @"NewsRatingLevel", @"NewsRatingName", @"NewsRatingDate"];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}


#pragma mark Property kvo

- (float)ChangeRange {
    return (self.Now - self.PrevClose) / self.PrevClose;
}

- (double)TtlAmount {
    return self.Now * self.TtlShr / 100000000.0;
}

// 设置依赖键(kvo)
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    
    if ([key isEqualToString:@"ChangeRange"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.PrevClose", nil];
    }
    
    if ([key isEqualToString:@"TtlAmount"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.TtlShr", nil];
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
    NSString *name = [_service getCurrentIndicateWithCode:code andName:@"Name"];
    [self setValue:name forKey:@"Name"];
    float prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] floatValue];
    [self setValue:[NSNumber numberWithFloat:prevClose] forKey:@"PrevClose"];
    float now = [[_service getCurrentIndicateWithCode:code andName:@"Now"] floatValue];
    [self setValue:[NSNumber numberWithFloat:now] forKey:@"Now"];
    float ttlShr = [[_service getCurrentIndicateWithCode:code andName:@"TtlShr"] floatValue];
    [self setValue:[NSNumber numberWithFloat:ttlShr] forKey:@"TtlShr"];
    int volumeSpread = [[_service getCurrentIndicateWithCode:code andName:@"VolumeSpread"] intValue];
    [self setValue:[NSNumber numberWithInt:volumeSpread] forKey:@"VolumeSpread"];
    float peTtm = [[_service getCurrentIndicateWithCode:code andName:@"PEttm"] floatValue];
    [self setValue:[NSNumber numberWithFloat:peTtm] forKey:@"PEttm"];
    int date = [[_service getCurrentIndicateWithCode:code andName:@"NewsRatingDate"] intValue];
    [self setValue:[NSNumber numberWithInt:date] forKey:@"NewsRatingDate"];
    int level = [[_service getCurrentIndicateWithCode:code andName:@"NewsRatingLevel"] intValue];
    [self setValue:[NSNumber numberWithInt:level] forKey:@"NewsRatingLevel"];
    NSString *label = [_service getCurrentIndicateWithCode:code andName:@"NewsRatingName"];
    [self setValue:label forKey:@"NewsRatingName"];
}


#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
    NSLog(@"%@ QuoteCellViewModel dealloc", self.Code);
}

@end
