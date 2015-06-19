//
//  BDPrompt.h
//  GoldenSignal
//
//  Created by Frank on 15/6/19.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDPrompt : NSObject

/**
 *  ID
 */
@property(nonatomic, assign) long innerId;

/**
 *  证券编码
 */
@property(nonatomic, strong) NSString *bdCode;

/**
 *  交易代码
 */
@property(nonatomic, strong) NSString *trdCode;

/**
 *  证券名称
 */
@property(nonatomic, strong) NSString *secuName;

/**
 *  标题
 */
@property(nonatomic, strong) NSString *title;

/**
 *  日期
 */
@property(nonatomic, strong) NSDate *date;

@end
