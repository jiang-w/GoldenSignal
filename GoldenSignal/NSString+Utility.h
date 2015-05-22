//
//  NSString+Utility.h
//  yicai_iso
//
//  Created by Frank on 14-7-28.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utility)

- (NSString*)md5;

- (BOOL)isNullOrEmpty;

/**
 *  计算显示文本所需的高度
 *
 *  @param font  显示的字体
 *  @param width 显示的宽度
 *
 *  @return 文本高度
 */
- (CGFloat)calculateTextHeight:(UIFont *)font width:(CGFloat)width;

/**
 *  计算显示文本所需的宽度
 *
 *  @param font   显示的字体
 *  @param height 显示的高度
 *
 *  @return 文本宽度
 */
- (CGFloat)calculateTextWidth:(UIFont *)font height:(CGFloat)height;

/**
 *  返回值是该字符串所占的大小
 *
 *  @param font     该字符串所用的字体(字体大小不一样,显示出来的面积也不同)
 *  @param maxSize  为限制改字体的最大宽和高(如果显示一行,则宽高都设置为MAXFLOAT, 如果显示为多行,只需将宽设置一个有限定长值,高设置为MAXFLOAT)
 *
 *  @return 字符串所占的大小
 */
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 *  判断字符串中是否包含中文
 */
- (BOOL)isIncludeChinese;

@end
