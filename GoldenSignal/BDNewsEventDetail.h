//
//  BDNewsEventDetail.h
//  GoldenSignal
//
//  Created by Frank on 15/7/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNewsEventDetail : NSObject

/**
 *  内部ID
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
 *  内容
 */
@property(nonatomic, strong) NSString *content;

/**
 *  作者
 */
@property(nonatomic, strong) NSString *author;

/**
 *  媒体
 */
@property(nonatomic, strong) NSString *media;

@end
