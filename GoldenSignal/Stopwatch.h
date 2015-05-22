//
//  Stopwatch.h
//  yicai_iso
//
//  Created by Frank on 14-8-8.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用于测量运行时间
 */
@interface Stopwatch : NSObject

/**
 *  运行时间（秒）
 */
@property (readonly) double elapsed;


/**
 *  开始测量运行时间
 */
- (void)start;


/**
 *  停止测量运行时间
 */
- (void)stop;


/**
 *  停止测量，运行时间重置为0，然后开始测量运行时间
 */
- (void)reset;


/**
 *  返回新的实例
 *
 */
+ (instancetype)startNew;

@end
