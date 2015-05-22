//
//  RelationQuery.m
//  UQuery
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDRelationQuery.h"

#define Type_Mapping_Json @[@"$and", @"$or"]
#define TypeToJsonString(type) ([Type_Mapping_Json objectAtIndex:type])
#define TypeFromJsonString(string) ([Type_Mapping_Json indexOfObject:string])

@implementation BDRelationQuery

#pragma mark Initialization
- (id)init
{
    if (self == [super init]) {
        _queries = [NSMutableSet setWithCapacity:2];
        _relation = andRelation;
    }
    return self;
}

- (instancetype)initWithRelation:(RelationType)relation andQuerise:(BDQuery *)query,...
{
    if (self = [self init]) {
        _relation = relation;
        
        NSMutableArray *querise = [NSMutableArray array];
        va_list argList;
        id arg = query;
        va_start(argList, query);
        while (arg) {
            [querise addObject:arg];
            arg = va_arg(argList,id);
        }
        va_end(argList);
        
        [self addQueriseFromArray:querise];
    }
    return self;
}

- (instancetype)initWithRelation:(RelationType)relation andQueryArray:(NSArray *)querise
{
    if (self = [self init]) {
        _relation = relation;
        [self addQueriseFromArray:querise];
    }
    return self;
}

- (void)addQueriseFromArray:(NSArray *)array
{
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[BDRelationQuery class]] && [(BDRelationQuery *)obj relation] == self.relation) {
            [self.queries unionSet:[obj queries]];
        }
        else {
            [self.queries addObject:obj];
        }
    }];
}

#pragma mark Serialize and Deserialize
- (NSString *)serializeToJson
{
    NSString *json;
    if ([_queries count] > 1) {
        NSMutableArray *items = [NSMutableArray array];
        for (BDQuery *fq in _queries) {
            [items addObject:[fq serializeToJson]];
        }
        json = [NSString stringWithFormat:@"{\"%@\":[%@]}"
                ,TypeToJsonString(_relation),[items componentsJoinedByString:@","]];
    }
    return json;
}

+ (instancetype)DeserializeFromJson:(NSString *)jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    
    RelationType typ = (int)TypeFromJsonString([[jsonDic allKeys] firstObject]);
    NSMutableArray *querise = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *values = [[jsonDic allValues] firstObject];
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([NSJSONSerialization isValidJSONObject:obj]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [querise addObject:[BDQuery DeserializeFromJson:json]];
        }
    }];
    
    BDRelationQuery *rq = [[BDRelationQuery alloc] initWithRelation:typ andQueryArray:querise];
    return rq;
}

#pragma mark Override
- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if ([object isMemberOfClass:[self class]]
        && _relation == [(BDRelationQuery *)object relation]
        && [_queries isEqualToSet:[object queries]]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSUInteger)hash
{
    return [[self serializeToJson] hash];
}

- (NSString *)description
{
    return [self serializeToJson];
}

@end
