//
//  BDUserInfo.h
//  yicai_iso
//
//  Created by Frank on 14-7-31.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDUserInfo : NSObject <NSCoding>

/**
 *  用户ID
 */
@property(nonatomic, strong) NSString *uid;

/**
 *  用户姓名
 */
@property(nonatomic, strong) NSString *name;

/**
 *  类型
 */
@property(nonatomic, assign) int type;

/**
 *  状态
 */
@property(nonatomic, assign) int status;

/**
 *  级别
 */
@property(nonatomic, assign) int level;

/**
 *  登录名
 */
@property(nonatomic, strong) NSString *loginName;

/**
 *  密码
 */
@property(nonatomic, strong) NSString *password;

@end
