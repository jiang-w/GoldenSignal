//
//  IdxTrendViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/6/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "QuoteHomeTrendViewModel.h"
#import "BDQuotationService.h"

@implementation QuoteHomeTrendViewModel
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
        indicaters = @[@"Name", @"Now", @"PrevClose", @"Open", @"Volume"];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}

#pragma mark Property kvo

- (double)ChangeRange {
    return (self.Now - self.PrevClose) / self.PrevClose;
}

- (double)Change {
    return (self.Now - self.PrevClose);
}

// 设置依赖键(kvo)
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    
    if ([key isEqualToString:@"ChangeRange"] || [key isEqualToString:@"Change"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.PrevClose", nil];
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
    NSString *name = [[[BDKeyboardWizard sharedInstance] queryWithSecuCode:code] name];
    [self setValue:name forKey:@"Name"];
    double prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:prevClose] forKey:@"PrevClose"];
    double open = [[_service getCurrentIndicateWithCode:code andName:@"Open"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:open] forKey:@"Open"];
    double now = [[_service getCurrentIndicateWithCode:code andName:@"Now"] doubleValue];
    [self setValue:[NSNumber numberWithDouble:now] forKey:@"Now"];
    unsigned long volume = [[_service getCurrentIndicateWithCode:code andName:@"Volume"] unsignedLongValue];
    [self setValue:[NSNumber numberWithUnsignedLong:volume] forKey:@"Volume"];
}


#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.Code indicaters:indicaters];
    NSLog(@"%@ IdxTrendViewModel dealloc", self.Code);
}

@end
