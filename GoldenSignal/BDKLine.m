//
//  BDKLine.m
//  CBNAPP
//
//  Created by Frank on 14/12/5.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDKLine.h"

@implementation BDKLine

- (id)copyWithZone:(NSZone *)zone
{
    BDKLine *copyLine = [[BDKLine allocWithZone:zone] init];
    copyLine.date = self.date;
    copyLine.high = self.high;
    copyLine.low = self.low;
    copyLine.open = self.open;
    copyLine.close = self.close;
    copyLine.volume = self.volume;
    return copyLine;
}

@end
