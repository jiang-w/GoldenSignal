//
//  BDSecuCode.h
//  CBNAPP
//
//  Created by Frank on 14/11/17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    stock = 10,
    idx = 13
} SecuType;

@interface BDSecuCode : NSObject

@property(nonatomic, strong)NSString *bdCode;

@property(nonatomic, strong)NSString *trdCode;

@property(nonatomic, strong)NSString *name;

@property(nonatomic, strong)NSString *py;

@property(nonatomic, assign)SecuType typ;

@property(nonatomic, strong)NSDate *updateTime;

@property(nonatomic, assign)int exchCode;

@end

