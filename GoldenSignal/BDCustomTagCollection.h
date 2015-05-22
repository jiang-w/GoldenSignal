//
//  BDCustomTagCollection.h
//  CBNAPP
//
//  Created by Frank on 14/10/21.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDCustomTagCollection : NSObject

@property(nonatomic, readonly, strong) NSMutableArray *tags;

+ (instancetype) sharedInstance;

/**
 *  判断是否包含此标签
 */
- (BOOL)IsCustomized:(BDNewsTag *)tag;


/**
 *  添加用户定制标签
 */
- (void)addTag:(BDNewsTag *)tag;


/**
 *  删除用户定制标签
 */
- (void)removeTagById:(long)tagId;


/**
 *  归档
 */
- (void)archive;


/**
 *  交换两个标签的位置
 */
- (void)exchangeTagAtIndex:(NSUInteger)index1 withTagAtIndex:(NSUInteger)index2;

@end
