//
//  LoginViewModel.h
//  yicai_iso
//
//  Created by Frank on 14-8-6.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    unknow = 0,
    success = 1,    //成功
    failure = 2,    //用户名密码错误
    paramError = 3, //参数错误
    bindError = 4,  //终端绑定失败
    bindlimit = 5,  //已达最大绑定上限数
    forbid = 6,     //未授权或服务已到期
    lock = 7,       //账号锁定
    noFound = 8,    //账号不存在
    noTest = 9,     //已达最大试用数
    other = 254    //其他错误
} LoginStatus;

@interface LoginViewModel : NSObject

@property NSString *loginName;
@property NSString *loginPwd;
@property (getter=getRemember,setter=setRemember:) BOOL remember;

/**
 *  用户登录
 *
 *
 *  @return 返回登录状态
 */
- (LoginStatus)login;

@end
