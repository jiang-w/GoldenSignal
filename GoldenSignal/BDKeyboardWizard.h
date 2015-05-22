//
//  BDKeyboardWizard.h
//  CBNAPP
//
//  Created by Frank on 14/11/20.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDKeyboardWizard : NSObject

+ (instancetype)sharedInstance;

- (BDSecuCode *)queryWithSecuCode:(NSString *)bdCode;

- (NSArray *)fuzzyQueryWithText:(NSString *)text;

- (void)requestServiceData;

@end
