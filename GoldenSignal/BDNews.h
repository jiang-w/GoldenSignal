//
//  BDNews.h
//  CBNAPP
//
//  Created by Frank on 14-8-13.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDNewsTag.h"

@interface BDNews : NSObject

/**
 *  新闻ID
 */
@property(nonatomic, assign) long innerId;

/**
 *  新闻标题
 */
@property(nonatomic, strong) NSString *title;

/**
 *  日期
 */
@property(nonatomic, strong) NSDate *date;

/**
 *  摘要
 */
@property(nonatomic, strong) NSString *abstract;

/**
 *  摘要全文
 */
@property(nonatomic, strong) NSString *ABST_SHT;

/**
 *  内容
 */
@property(nonatomic, strong) NSString *content;

/**
 *  公司名字
 */
@property(nonatomic, strong) NSString *companyName;

/**
 *  作者
 */
@property(nonatomic, strong) NSString *author;

/**
 *  媒体
 */
@property(nonatomic, strong) NSString *media;

/**
 *  每条新闻对应的连接ID 有可能为空
 */
@property (nonatomic,assign) long connectId;


@end
