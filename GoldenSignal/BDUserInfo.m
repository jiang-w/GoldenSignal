//
//  BDUserInfo.m
//  yicai_iso
//
//  Created by Frank on 14-7-31.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDUserInfo.h"

@implementation BDUserInfo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeInt:_status forKey:@"status"];
    [aCoder encodeInt:_level forKey:@"level"];
    [aCoder encodeObject:_loginName forKey:@"loginName"];
    [aCoder encodeObject:_password forKey:@"password"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.type = [aDecoder decodeInt32ForKey:@"type"];
        self.status = [aDecoder decodeInt32ForKey:@"status"];
        self.level = [aDecoder decodeInt32ForKey:@"level"];
        self.loginName = [aDecoder decodeObjectForKey:@"loginName"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

@end
