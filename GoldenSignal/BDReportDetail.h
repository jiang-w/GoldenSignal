//
//  BDReportDetail.h
//  GoldenSignal
//
//  Created by Frank on 15/7/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDReportDetail : NSObject

/**
 *  研报ID
 */
@property(nonatomic, assign) long innerId;

/**
 *  研报标题
 */
@property(nonatomic, strong) NSString *title;

/**
 *  日期
 */
@property(nonatomic, strong) NSDate *date;

/**
 *  当前评级
 */
@property(nonatomic, strong) NSString *rating;

/**
 *  评级对应的Code
 */
@property(nonatomic, assign) int rat_code;

/**
 *  机构
 */
@property(nonatomic, strong) NSString *com;

/**
 *  作者
 */
@property(nonatomic, strong) NSString *author;

/**
 *  目标价
 */
@property(nonatomic, assign) float targ_prc;

/**
 *  全部内容
 */
@property(nonatomic, strong) NSString *content;

@end
