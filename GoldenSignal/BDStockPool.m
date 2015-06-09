//
//  BDStockPool.m
//  CBNAPP
//
//  Created by Frank on 15/1/14.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDStockPool.h"

@implementation BDStockPool
{
    NSMutableArray *_codeArray;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t  onceToken;
    static BDStockPool *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDStockPool alloc] init];
        sharedInstance->_codeArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"StockPool"]];
    });
    return sharedInstance;
}

- (void)addStockWithCode:(NSString *)code {
    if (code != nil) {
        for (NSString *bdCode in _codeArray) {
            if ([bdCode isEqualToString:code]) {
                return;
            }
        }
        [_codeArray addObject:code];
        [[NSUserDefaults standardUserDefaults] setObject:_codeArray forKey:@"StockPool"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification postNotificationName:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil userInfo:@{@"op": @"add"}];
    }
}

- (void)removeStockWithCode:(NSString *)code {
    if (code != nil) {
        int i = 0;
        BOOL deleted = NO;
        while (i < _codeArray.count) {
            if ([_codeArray[i] isEqualToString:code]) {
                [_codeArray removeObjectAtIndex:i];
                deleted = YES;
            }
            else {
                i++;
            }
        }
        
        if (deleted) {
            [[NSUserDefaults standardUserDefaults] setObject:_codeArray forKey:@"StockPool"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
            [notification postNotificationName:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil userInfo:@{@"op": @"remove"}];
        }
    }
}

- (BOOL)containStockWithCode:(NSString *)code {
    if (code != nil) {
        for (NSString *bdCode in _codeArray) {
            if ([bdCode isEqualToString:code]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray *)codes {
    return [NSArray arrayWithArray:_codeArray];
}

@end
