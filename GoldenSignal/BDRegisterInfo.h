//
//  BDRegisterInfo.h
//  yicai_iso
//
//  Created by Frank on 14-8-4.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDRegisterInfo : NSObject

/**
 *  登录名
 */
@property(nonatomic, strong) NSString *loginName;

/**
 *  密码
 */
@property(nonatomic, strong) NSString *password;

/**
 *  手机号
 */
@property(nonatomic, strong) NSString *phone;

/**
 *  验证码
 */
@property(nonatomic, strong) NSString *vCode;

/**
 *  电子邮箱
 */
@property(nonatomic, strong) NSString *eMail;

/**
 *  角色
 */
@property(nonatomic, strong) NSString *role;

/**
 *  初始化用户注册信息
 *
 *  @param loginName 用户名
 *  @param password  密码
 *  @param phone     手机号
 *  @param eMail     电子邮箱
 *  @param vCode     验证码
 *
 *  @return 返回用户注册信息实例
 */
- (instancetype)initWithLoginName:(NSString *)loginName password:(NSString *)password phone:(NSString *)phone eMail:(NSString *)email vCode:(NSString *)vCode;

/**
 *  将注册信息序列化为Json
 *
 *  @return 返回Json格式字符串
 */
- (NSString *)serializeToJson;

@end
