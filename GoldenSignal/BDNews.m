//
//  BDNews.m
//  CBNAPP
//
//  Created by Frank on 14-8-13.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDNews.h"

@implementation BDNews

- (id)init
{
    if(self = [super init]) {
        self.labels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (NSArray *)getLabelsWithEventEffect:(EventEffect) effect
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"effect == %d",effect];
    return [self.labels filteredArrayUsingPredicate:predicate];
}

@end
