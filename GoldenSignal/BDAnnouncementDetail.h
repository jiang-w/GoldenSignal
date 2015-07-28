//
//  BDAnnouncementDetail.h
//  GoldenSignal
//
//  Created by Frank on 15/7/28.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDAnnouncementDetail : NSObject

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
 *  内容
 */
@property (nonatomic, copy) NSString *content;

/**
 *  附件格式（PDF、DOC ...）
 */
@property (nonatomic, copy) NSString *ann_fmt;

/**
 *  附件ID
 */
@property (nonatomic, assign) long ann_cont_id;


@end
