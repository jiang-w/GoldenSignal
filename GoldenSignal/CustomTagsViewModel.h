//
//  CustomTagsViewModel.h
//  CBNAPP
//
//  Created by Frank on 14-10-13.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomTagsViewModel : NSObject

/**
 *  选中的一级标签
 */
@property(nonatomic, strong) BDNewsTag *selectedTag;

/**
 *  一级标签
 */
@property(nonatomic, readonly, getter = getTopTags) NSArray *topTags;


/**
 *  二级标签
 */
@property(nonatomic, readonly, getter = getSubTags) NSArray *subTags;


/**
 *  添加用户定制标签
 *
 *  @param label 要添加的标签
 */
- (void)addTag:(BDNewsTag *)tag;


/**
 *  删除用户定制标签
 *
 *  @param labelId 要删除的标签ID
 */
- (void)removeTagById:(long)tagId;

@end
