//
//  BDSecuNews.h
//  GoldenSignal
//
//  Created by Frank on 15/7/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSecuNews : NSObject

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
 *  内容ID
 */
@property(nonatomic, assign) long contentId;

/**
 *  作者
 */
@property(nonatomic, strong) NSString *author;

/**
 *  媒体
 */
@property(nonatomic, strong) NSString *media;

@end
