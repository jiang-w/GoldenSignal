//
//  BDAnnouncementList.h
//  CBNAPP
//
//  Created by Frank on 14/12/17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDAnnouncementList : NSObject

/**
 *  内部ID
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
 *  内容ID
 */
@property(nonatomic, assign) long contentId;

/**
 *  详情页面的内容
 */
//@property (nonatomic, copy) NSString *content;

@end
