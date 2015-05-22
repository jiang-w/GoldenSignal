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
 *  序号
 */
@property(nonatomic, assign) long sn;

@end
