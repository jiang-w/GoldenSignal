//
//  BDUserTicket.m
//  yicai_iso
//
//  Created by Frank on 14-7-31.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDUserTicket.h"
#import "NSString+Utility.h"
#import "BDNetworkService.h"

@implementation BDUserTicket

- (instancetype)initWithLoginName:(NSString *)loginName password:(NSString *)password {
    if (self = [super init]) {
        self.loginName = loginName;
        self.loginPwd = password;
        self.productId = PRODUCT_SN;
        self.macAddress = [[BDNetworkService sharedInstance] getMacAddress];
        self.computerSN = @"";
        self.computerName = @"";
    }
    return self;
}

- (NSString *)serializeToJson {
    NSString *json = [NSString stringWithFormat:@"{\"LoginName\":\"%@\",\"LoginPwd\":\"%@\",\"ProductID\":\"%@\",\"MACAddress\":\"%@\",\"ComputerSN\":\"%@\",\"ComputerName\":\"%@\"}", self.loginName, [self.loginPwd md5], self.productId, self.macAddress, self.computerSN, self.computerName];
    return json;
}

@end
