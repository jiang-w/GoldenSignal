//
//  BDBulletin.h
//  CBNAPP
//
//  Created by Frank on 14/12/17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDBulletin : NSObject

/**
 *  公告ID
 */
@property(nonatomic, assign) long innerId;

/**
 *  公告标题
 */
@property(nonatomic, strong) NSString *title;

/**
 *  日期
 */
@property(nonatomic, strong) NSDate *date;

/**
 *  序号
 */
@property(nonatomic, assign) long sn;


/**
 *  每条新闻对应的连接ID 有可能为空
 */
@property (nonatomic,assign) long connectId;

/**
 *  详情页面的内容
 */
@property (nonatomic, copy) NSString *content;

@end
