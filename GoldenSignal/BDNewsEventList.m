//
//  BDNewsEvent.m
//  GoldenSignal
//
//  Created by Frank on 15/7/21.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDNewsEventList.h"

@implementation BDNewsEventList

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
