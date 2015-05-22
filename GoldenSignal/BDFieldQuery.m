//
//  FieldQuery.m
//  Uquery
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDFieldQuery.h"

#define Default_Date_Format @"yyyy-MM-dd'T'HH:mm:ss"
#define Type_Mapping_Json @[@"$gt", @"$gte", @"$lt", @"$lte", @"$eq", @"$ne", @"$in", @"$nin",@"$lk"]
#define TypeToJsonString(type) ([Type_Mapping_Json objectAtIndex:type])
#define TypeFromJsonString(string) ([Type_Mapping_Json indexOfObject:string])

@implementation BDFieldQuery

#pragma mark Initialization
- (instancetype)initKey:(NSString *)key andValue:(NSObject *)val andQueryType:(QueryType)typ
{
    if (self = [super init]) {
        _key = key;
        _value = val;
        _type = typ;
    }
    return self;
}

#pragma mark Serialize and Deserialize
- (NSString *)serializeToJson
{
    NSString *json;
    id val;
    if([_value isKindOfClass:[NSDate class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:Default_Date_Format];
        val = [dateFormatter stringFromDate:[NSDate date]];
    }
    else {
        val = _value;
    }
    
    if (_type != equal) {
        NSDictionary *tmp = [NSDictionary dictionaryWithObject:val forKey:TypeToJsonString(_type)];
        val = tmp;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:val forKey:_key];
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return json;
}

+ (instancetype)DeserializeFromJson:(NSString *)jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    return [BDFieldQuery generateFromDictionary:jsonDic];
}

+ (instancetype)generateFromDictionary:(NSDictionary *)dictionary
{
    BDFieldQuery *query;
    if([dictionary count] == 1)
    {
        NSString *key = [[dictionary allKeys] firstObject];
        id value = [[dictionary allValues] firstObject];
        QueryType type = equal;
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            type = (int)TypeFromJsonString([[value allKeys] firstObject]);
            value = [[value allValues] firstObject];
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:Default_Date_Format];
            NSDate *date =[dateFormatter dateFromString:value];
            if(date) {
                value = date;
            }
        }
        
        query = [[BDFieldQuery alloc] initKey:key andValue:value andQueryType:type];
    }
    return query;
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
    if ([object isMemberOfClass:[self class]]) {
        if([[self serializeToJson] isEqualToString:[object serializeToJson]]) {
            return YES;
        }
        else {
            return NO;
        }
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
