//
//  BDStockPool.h
//  CBNAPP
//
//  Created by Frank on 15/1/14.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDStockPool : NSObject

@property(nonatomic, strong ,readonly)NSArray *codes;

+ (instancetype)sharedInstance;

- (void)addStockWithCode:(NSString *)code;

- (void)removeStockWithCode:(NSString *)code;

- (BOOL)containStockWithCode:(NSString *)code;

@end
