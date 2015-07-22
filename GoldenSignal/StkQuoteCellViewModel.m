//
//  QuoteCellViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "StkQuoteCellViewModel.h"
#import "BDQuotationService.h"

@implementation StkQuoteCellViewModel
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

- (double)ChangeRange {
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
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
    [self setValue:secu.trdCode forKey:@"TrdCode"];
    [self setValue:secu.name forKey:@"Name"];
    
    double prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:prevClose] forKey:@"PrevClose"];
    double now = [[_service getCurrentIndicateWithCode:code andName:@"Now"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:now] forKey:@"Now"];
    double ttlShr = [[_service getCurrentIndicateWithCode:code andName:@"TtlShr"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:ttlShr] forKey:@"TtlShr"];
    unsigned long volumeSpread = [[_service getCurrentIndicateWithCode:code andName:@"VolumeSpread"] unsignedLongValue];
    [self setValue:[NSNumber numberWithUnsignedLong:volumeSpread] forKey:@"VolumeSpread"];
    double peTtm = [[_service getCurrentIndicateWithCode:code andName:@"PEttm"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:peTtm] forKey:@"PEttm"];
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
    if (self.Code) {
        [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
    }
//    NSLog(@"StkQuoteCellViewModel dealloc (%@)", self.Code);
}

@end
