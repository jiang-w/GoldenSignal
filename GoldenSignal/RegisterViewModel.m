//
//  RegisterViewModel.m
//  yicai_iso
//
//  Created by Frank on 14-8-6.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "RegisterViewModel.h"
#import "BDNetworkService.h"

@implementation RegisterViewModel

- (RegisterStatus)registerUser {
    BDRegisterInfo *info = [[BDRegisterInfo alloc] initWithLoginName:self.loginName password:self.pwd phone:self.phone eMail:self.eMail vCode:self.vCode];
    info.role = @"normal";
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"RegisterInfoService.Set" forKey:@"Service"];
    [parameters setValue:@"SetService" forKey:@"Function"];
    [parameters setValue:@"ADD" forKey:@"FLAG"];
    [parameters setValue:info.loginName forKey:@"USER_ID"];
    [parameters setValue:info.loginName forKey:@"USER_NAME"];
    [parameters setValue:info.loginName forKey:@"LOG_NAME"];
    [parameters setValue:[info.password md5] forKey:@"LOG_PWD"];
    [parameters setValue:info.eMail forKey:@"E_MAIL"];
    [parameters setValue:info.phone forKey:@"MOBILE"];
    NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
    
    NSRange r1 = {0, 1};
    Byte flag1;
    [data getBytes:&flag1 range:r1];
    RegisterStatus status = (RegisterStatus)flag1;
    
    if (status == success) {
        [parameters removeAllObjects];
        [parameters setValue:@"UserRoleService.Create" forKey:@"Service"];
        [parameters setValue:@"CreateService" forKey:@"Function"];
        [parameters setValue:info.loginName forKey:@"USER_ID"];
        [parameters setValue:PRODUCT_SN forKey:@"PROD_ID"];
        [parameters setValue:info.role forKey:@"ROLE_CODE"];
        [parameters setValue:[NSNumber numberWithInt:0] forKey:@"BIND_MACH_NUM"];
        [parameters setValue:[[NSDate date] toString:@"yyyy-MM-dd hh:mm:ss"] forKey:@"SVC_BGN_DT"];
        [parameters setValue:[[[NSDate date] addDays:365*3] toString:@"yyyy-MM-dd hh:mm:ss" ] forKey:@"SVC_END_DT"];
        [parameters setValue:[NSNumber numberWithInt:0] forKey:@"SOUR_CODE"];
        [parameters setValue:@"" forKey:@"RECOMM"];
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        
        [data getBytes:&flag1 range:r1];
        operStatus opStatus = (operStatus)flag1;
        if (opStatus != ok) {
            status = failure;
        }
    }
    
    return status;
}

@end
