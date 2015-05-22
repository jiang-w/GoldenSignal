//
//  BDNewsTag.h
//  GoldSignal
//
//  Created by Frank on 14-8-26.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TagType
{
    Channel = 1,    // 栏目标签
    Stock = 2,      // 个股标签
    Sectoral = 3    // 板块标签
} TagType;

typedef enum EventEffect
{
    PositivePlus = 0,   // 正面重大
    Positive = 1,       // 正面
    Neutral = 2,        // 中性
    Negative = 3,       // 负面
    NegativeMinus = 4,  // 负面重大
    None = 5            // 无
} EventEffect;

@interface BDNewsTag : NSObject <NSCoding>

/**
 *  标签id
 */
@property(nonatomic, assign) long innerId;

/**
 *  标签名称
 */
@property(nonatomic, strong) NSString *name;

/**
 *  标签类型
 */
@property(nonatomic, assign) TagType type;

/**
 *  父标签id
 */
@property(nonatomic, assign) long parentId;

/**
 *  事件影响
 */
@property(nonatomic, assign) EventEffect effect;

/**
 *  证券编码
 */
@property(nonatomic, strong) NSString *bdCode;

@end
