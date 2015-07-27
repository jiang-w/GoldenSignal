//
//  BDSecuNewsList.h
//  GoldenSignal
//
//  Created by Frank on 15/7/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NWS = 1,    // 新闻
    RPT = 2,    // 研报
    ANNC = 3    // 公告
} NewsType;

// 证券新闻资讯model
@interface BDSecuNewsList : NSObject

/**
 *  内部ID
 */
@property(nonatomic, assign) long innerId;

/**
 *  标题
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
 *  资讯内容
 */
@property(nonatomic, assign) NewsType type;

@end
