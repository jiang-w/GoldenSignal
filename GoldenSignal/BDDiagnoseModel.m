//
//  BDDiagnoseModel.m
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDDiagnoseModel.h"

@implementation BDDiagnoseModel

//KVC 赋值
- (instancetype)initWithDictionary:(NSMutableDictionary *)jsonObject{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:jsonObject];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    [super setValue:value forUndefinedKey:key];
}



@end
