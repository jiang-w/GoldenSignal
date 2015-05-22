//
//  LoginViewModel.m
//  yicai_iso
//
//  Created by Frank on 14-8-6.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "LoginViewModel.h"
#import "BDNetworkService.h"
#import "BDCoreService.h"

#define DocPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/user.arc"]

@implementation LoginViewModel
{
    BDUserInfo *_userInfo;
}

- (BOOL)getRemember {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remember"];
}

- (void)setRemember:(BOOL)remember {
    [[NSUserDefaults standardUserDefaults] setBool:remember forKey:@"remember"];
}

- (instancetype)init {
    if (self = [super init]) {
        _userInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:DocPath];
        self.loginName = _userInfo.loginName;
        self.loginPwd = _userInfo.password;
    }
    return self;
}

// 用户登录
- (LoginStatus)login {
    BDUserTicket *ticket = [[BDUserTicket alloc] initWithLoginName:self.loginName password:self.loginPwd];
    ticket.computerSN = @"";
    ticket.computerName = [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];

    NSHTTPURLResponse *response;
    NSError *error;
    
    //    NSString *url = [NSString stringWithFormat:GETURL@"Service=LoginService.Get&Function=GetService&PassPort=%@&ATYPE=JSON", [userTicket serializeToJson]];
    //    NSString* escapedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSData *data = [[BDNetworkService sharedInstance] syncGetRequest:escapedUrlString returnResponse:&response error:&error];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"LoginService.Get" forKey:@"Service"];
    [parameters setValue:@"GetService" forKey:@"Function"];
    [parameters setValue:[ticket serializeToJson] forKey:@"PassPort"];
    [parameters setValue:@"JSON" forKey:@"ATYPE"];
    NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
    
    NSRange r1 = {0, 1};
    Byte flag1;
    [data getBytes:&flag1 range:r1];
    LoginStatus status = (LoginStatus)flag1;
    
    if (status == success && self.remember) {
        // 将用户信息对象归档
        BDUserInfo *userInfo = [self paraseUserInfo:data];
        userInfo.loginName = self.loginName;
        userInfo.password = self.loginPwd;
        _userInfo = userInfo;
        [NSKeyedArchiver archiveRootObject:_userInfo toFile:DocPath];
    }
    
    return status;
}

// 解析用户信息
- (BDUserInfo *)paraseUserInfo:(NSData *)data {
    BDCoreService *service = [[BDCoreService alloc] init];
    NSArray *allData = [service dataConvertToNSArray:data];
    NSDictionary *userData = [[[allData objectAtIndex:0] objectForKey:@"DATA"] objectAtIndex:0];
    
    BDUserInfo *userInfo = [[BDUserInfo alloc] init];
    userInfo.uid = [userData objectForKey:@"USERID"];
    userInfo.name = [userData objectForKey:@"USERNAME"];
    userInfo.type = [[userData objectForKey:@"USERTYP"] isKindOfClass:[NSNull class]]?0:[[userData objectForKey:@"USERTYP"] intValue];
    userInfo.status = [[userData objectForKey:@"USERSTS"] isKindOfClass:[NSNull class]]?0:[[userData objectForKey:@"USERSTS"] intValue];
    userInfo.level = [[userData objectForKey:@"USERLVL"] isKindOfClass:[NSNull class]]?0:[[userData objectForKey:@"USERLVL"] intValue];
    
    return userInfo;
}

@end
