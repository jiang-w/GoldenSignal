//
//  Stopwatch.m
//  yicai_iso
//
//  Created by Frank on 14-8-8.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "Stopwatch.h"

@implementation Stopwatch
{
    NSDate *startTimeStamp;
    BOOL isRunning;
}

- (id)init {
    if (self = [super init]) {
        isRunning = NO;
        _elapsed = 0;
    }
    return self;
}

- (void)start {
    if (!isRunning) {
        isRunning = YES;
        startTimeStamp = [NSDate date];
    }
}

- (void)stop {
    if (isRunning) {
        isRunning = false;
        _elapsed += [[NSDate date] timeIntervalSinceDate:startTimeStamp];
    }
}

- (void)reset {
    isRunning = NO;
    _elapsed = 0;
    startTimeStamp = [NSDate date];
}

+ (instancetype)startNew {
    Stopwatch *new = [[Stopwatch alloc] init];
    [new start];
    return new;
}

@end
