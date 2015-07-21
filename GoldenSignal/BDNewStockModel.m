//
//  BDNewStockModel.m
//  GoldenSignal
//
//  Created by CBD on 7/8/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "BDNewStockModel.h"//要闻 的 新股Model

@implementation BDNewStockModel

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
