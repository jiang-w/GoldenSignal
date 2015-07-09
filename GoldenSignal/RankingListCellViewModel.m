//
//  RankingListCellViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/7/9.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "RankingListCellViewModel.h"
#import "BDQuotationService.h"

#define IndicaterNames @[@"Now", @"PrevClose"]

@implementation RankingListCellViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
}

- (id)init {
    self = [super init];
    if (self) {
        _propertyUpdateQueue = dispatch_queue_create("IndicatorUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}


#pragma mark Property kvo

- (double)Change {
    return self.Now - self.PrevClose;
}

- (double)ChangeRange {
    return (self.Now - self.PrevClose) / self.PrevClose;
}

// 设置依赖键(kvo)
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    
    if ([key isEqualToString:@"Change"] || [key isEqualToString:@"ChangeRange"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"self.Now", @"self.PrevClose", nil];
    }

    if (moreKeyPaths) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:moreKeyPaths];
    }
    return keyPaths;
}


#pragma mark Subscribe

- (void)loadDataWithCode:(NSString *)code {
    if (code != nil && ![code isEqualToString:self.Code]) {
        if (self.Code != nil) {
            [_service unsubscribeScalarWithCode:self.Code indicaters:IndicaterNames];
        }
        [self initPropertyWithCode:code];
        [_service subscribeScalarWithCode:code indicaters:IndicaterNames];
    }
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if ([code isEqualToString: self.Code] && [IndicaterNames containsObject:indicateName]) {
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
}


#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.Code indicaters:IndicaterNames];
//    NSLog(@"%@ RankingListCellViewModel dealloc", self.Code);
}

@end
