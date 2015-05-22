//
//  BDUserTicket.h
//  yicai_iso
//
//  Created by Frank on 14-7-31.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDUserTicket : NSObject

/**
 *  用户名
 */
@property(nonatomic, strong) NSString *loginName;

/**
 *  密码
 */
@property(nonatomic, strong) NSString *loginPwd;

/**
 *  产品ID
 */
@property(nonatomic, strong) NSString *productId;

/**
 *  mac地址
 */
@property(nonatomic, strong) NSString *macAddress;

/**
 *  设备的标识符
 */
@property(nonatomic, strong) NSString *computerSN;

/**
 *  设备名称
 */
@property(nonatomic, strong) NSString *computerName;

- (instancetype)initWithLoginName:(NSString *)loginName password:(NSString *)password;
- (NSString *)serializeToJson;

@end
