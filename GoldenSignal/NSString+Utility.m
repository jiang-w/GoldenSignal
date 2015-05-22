//
//  NSString+Utility.m
//  yicai_iso
//
//  Created by Frank on 14-7-28.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "NSString+Utility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utility)

- (NSString*)md5
{
    if (![self isNullOrEmpty]) {
        // Create pointer to the string as UTF8
        const char *ptr = [self UTF8String];
        
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(ptr, (uint)strlen(ptr), md5Buffer);
        
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x",md5Buffer[i]];
        
        return output;
    }
    else {
        return @"";
    }
}

- (BOOL)isNullOrEmpty
{
    if (self == nil || [self isEqualToString:@""]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (CGFloat)calculateTextHeight:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
    CGFloat delta = size.height;
    return delta;
}

- (CGFloat)calculateTextWidth:(UIFont *)font height:(CGFloat)height {
    CGSize size = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
    CGFloat delta = size.width;
    return delta;
}

-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}

- (BOOL)isIncludeChinese {
    for (int i=0; i<self.length; i++) {
        unichar ch = [self characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}

@end
