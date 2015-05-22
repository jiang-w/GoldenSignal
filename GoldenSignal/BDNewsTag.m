//
//  BDNewsLabel.m
//  GoldSignal
//
//  Created by Frank on 14-8-26.
//  Copyright (c) 2014年 ZYX. All rights reserved.
//

#import "BDNewsTag.h"

@implementation BDNewsTag

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_innerId forKey:@"id"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeInt64:_parentId forKey:@"pid"];
    [aCoder encodeInt:_effect forKey:@"effect"];
    [aCoder encodeObject:_bdCode forKey:@"bdCode"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.innerId = (long)[aDecoder decodeInt64ForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.type = [aDecoder decodeInt32ForKey:@"type"];
        self.parentId = (long)[aDecoder decodeInt64ForKey:@"pid"];
        self.effect = [aDecoder decodeInt32ForKey:@"effect"];
        self.bdCode = [aDecoder decodeObjectForKey:@"bdCode"];
    }
    return self;
}

@end
