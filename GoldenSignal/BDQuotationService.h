//
//  BDQuotationService.h
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface BDQuotationService : NSObject

+ (instancetype) sharedInstance;

- (void)subscribeScalarWithCode:(NSString *)code indicaters:(NSArray *)names;

- (void)unsubscribeScalarWithCode:(NSString *)code indicaters:(NSArray *)names;

- (void)subscribeSerialsWithCode:(NSString *)code indicateName:(NSString *)name beginDate:(int)date beginTime:(int)time numberType:(int)type number:(int)number;

- (id)getCurrentIndicateWithCode:(NSString *)code andName:(NSString *)name;

- (void)connect;

- (void)disconnect;

- (BOOL)isConnected;

- (void)resubmit;

- (RACSignal *)scalarSignalWithCode:(NSString *)code andIndicater:(NSString *)name;

@end
