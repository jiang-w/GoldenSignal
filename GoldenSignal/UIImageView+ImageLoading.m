//
//  UIImageView+ImageLoading.m
//  CBNAPP
//
//  Created by Frank on 14-8-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "UIImageView+ImageLoading.h"

@implementation UIImageView (ImageLoading)

- (void)setImageWithUrl:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
        });
    });
}

@end
