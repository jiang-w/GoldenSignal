//
//  Uquery.h
//  Uquery
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDQuery : NSObject

- (NSString *)serializeToJson;
+ (instancetype)DeserializeFromJson:(NSString *)jsonString;
+ (instancetype)greaterWithKey:(NSString *)key andValue:(NSObject *)val;
+ (instancetype)greaterOrEqualWithKey:(NSString *)key andValue:(NSObject *)val;
+ (instancetype)lessWithKey:(NSString *)key andValue:(NSObject *)val;
+ (instancetype)lessOrEqualWithKey:(NSString *)key andValue:(NSObject *)val;
+ (instancetype)equalWithKey:(NSString *)key andValue:(NSObject *)val;
+ (instancetype)notEqualWithKey:(NSString *)key andValue:(NSObject *)val;
+ (instancetype)andRelationWithQuerise:(BDQuery *)query, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)orRelationWithQuerise:(BDQuery *)query, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)betweenWithKey:(NSString *)key fromValue:(NSObject *)from toValue:(NSObject *)to;
+ (instancetype)inWithKey:(NSString *)key fromArray:(NSArray *)array;
+ (instancetype)likeWithKey:(NSString *)key andRegexString:(NSString *)regexString;

@end

