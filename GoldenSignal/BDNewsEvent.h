//
//  BDNewsEvent.h
//  GoldenSignal
//
//  Created by Frank on 15/7/21.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNewsEvent : NSObject

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

/**
 *  新闻标签
 */
@property(nonatomic, strong) NSMutableArray *labels;


/**
 *  获取某类型的新闻标签
 *
 *  @param effect 事件影响
 *
 *  @return 返回标签数组
 */
- (NSArray *)getLabelsWithEventEffect:(EventEffect) effect;

@end
