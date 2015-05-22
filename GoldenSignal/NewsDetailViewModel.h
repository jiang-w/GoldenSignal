//
//  NewsDetailViewModel.h
//  CBNAPP
//
//  Created by Frank on 14/11/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDetailViewModel : NSObject

/**
 *  根据ID获取新闻
 *
 *  @param newsId       新闻ID
 */
- (BDNews *)getNewsById:(long)newsId;

@end
