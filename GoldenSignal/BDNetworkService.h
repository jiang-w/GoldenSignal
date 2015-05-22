//
//  BDDataService.h
//  yicai_iso
//
//  Created by Frank on 14-7-30.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNetworkService : NSObject

/**
 *  网络状态
 */
@property(nonatomic, readonly, assign) NetworkStatus networkStatus;


/**
 *  
 *
 *  @return 返回单例对象
 */
+ (instancetype) sharedInstance;

/**
 *  异步POST方式请求
 *
 *  @param urlString  url字符串
 *  @param parameters POST请求的参数
 *  @param success    请求成功后执行的代码块
 *  @param failure    请求失败执行的代码块
 */
- (void)asyncPostRequest:(NSString *)urlString parameters:(NSDictionary *)parameters
     success:(void(^)(id responseObject))success
     failure:(void(^)(NSError *error))failure;

/**
 *  异步GET方式请求
 *
 *  @param urlString url字符串
 *  @param success   请求成功后执行的代码块
 *  @param failure   请求失败执行的代码块
 */
- (void)asyncGetRequest:(NSString *) urlString success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

/**
 *  同步POST方式请求
 *
 *  @param urlString url字符串
 *  @param parameter POST请求的参数
 *  @param response  请求响应
 *  @param error     错误
 *
 *  @return 返回请求的数据
 */
- (NSData *)syncPostRequest:(NSString *)urlString parameters:(NSDictionary *) parameter returnResponse:(NSHTTPURLResponse **)response error:(NSError **) error;

/**
 *  同步GET方式请求
 *
 *  @param urlString url字符串
 *  @param response  请求响应
 *  @param error     错误
 *
 *  @return 返回请求的数据
 */
- (NSData *)syncGetRequest:(NSString *)urlString returnResponse:(NSHTTPURLResponse **)response error:(NSError **) error;

/**
 *  获取MAC地址
 *
 *  @return 返回MAC地址字符串
 */
- (NSString *)getMacAddress;

@end
