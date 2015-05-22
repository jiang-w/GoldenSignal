//
//  FieldQuery.h
//  Uquery
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDQuery.h"

typedef enum {
    greater,
    greaterOrEqual,
    less,
    lessOrEqual,
    equal,
    notEqual,
    in,
    notIn,
    like
} QueryType;

@interface BDFieldQuery : BDQuery

@property (readonly) NSString *key;
@property (readonly) NSObject *value;
@property (readonly) QueryType type;

- (instancetype)initKey:(NSString *)key andValue:(NSObject *)val andQueryType:(QueryType)typ;

@end

