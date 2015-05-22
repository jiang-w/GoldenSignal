//
//  BDRegisterInfo.m
//  yicai_iso
//
//  Created by Frank on 14-8-4.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDRegisterInfo.h"
#import "NSString+Utility.h"

@implementation BDRegisterInfo

- (instancetype)initWithLoginName:(NSString *)loginName password:(NSString *)password phone:(NSString *)phone eMail:(NSString *)email vCode:(NSString *)vCode {
    if (self = [super init]) {
        self.loginName = loginName;
        self.password = password;
        self.phone = phone;
        self.vCode = vCode;
        self.eMail = email;
    }
    return self;
}

- (NSString *)serializeToJson {
    NSString *json = [NSString stringWithFormat:@"{\"LoginName\":\"%@\",\"Password\":\"%@\",\"Phone\":\"%@\",\"vCode\":\"%@\"}", self.loginName, [self.password md5], self.phone, self.vCode];
    return json;
}

@end
