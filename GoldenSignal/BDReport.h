//
//  BDReport.h
//  CBNAPP
//
//  Created by Frank on 14/12/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDReport : NSObject

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
@property(nonatomic, assign) long RAT_CODE;


/**
 *  机构
 */
@property(nonatomic, strong) NSString *com;

/**
 *  作者
 */
@property(nonatomic, strong) NSString *aut;

/**
 *  目标价
 */
@property(nonatomic, assign) float targ_prc;

/**
 *  摘要
 */
@property(nonatomic, strong) NSString *abst;

/**
 *  摘要全文
 */
@property(nonatomic, copy) NSString *abstsht;

/**
 *  序号
 */
@property(nonatomic, assign) long sn;



@end
