//
//  RegisterViewModel.h
//  yicai_iso
//
//  Created by Frank on 14-8-6.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    unknow = 0,
    success = 1,    //成功
    failure = 2,    //失败
    paramError = 3, //参数错误
    loginNameUnavailable = 4,  //登录名不可用
    loginNameAvailable = 5,  //登录名可用
    EmailUnavailable = 6,     //邮箱不可用
    other = 254    //其他错误
} RegisterStatus;

@interface RegisterViewModel : NSObject

@property NSString *loginName;
@property NSString *pwd;
@property NSString *pwdAgain;
@property NSString *phone;
@property NSString *vCode;
@property NSString *eMail;

/**
 *  注册用户
 *
 *  @return 返回操作码
 */
- (RegisterStatus)registerUser;

@end
