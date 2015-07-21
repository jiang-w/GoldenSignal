//
//  NewsDetailViewModel.m
//  CBNAPP
//
//  Created by Frank on 14/11/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "NewsDetailViewModel.h"
#import "BDNewsService.h"

@implementation NewsDetailViewModel
{
    BDNewsService *_servive;
}

- (id)init {
    self = [super init];
    if (self) {
        _servive = [BDNewsService new];
    }
    return self;
}

- (BDNews *)getNewsById:(long)newsId {
    return [_servive getNewsEventById:newsId];
}

@end
