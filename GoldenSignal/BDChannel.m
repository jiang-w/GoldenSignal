//
//  BDColumn.m
//  CBNAPP
//
//  Created by Frank on 14-9-1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDChannel.h"

@implementation BDChannel

+ (BDChannel *)createWithName:(NSString *)name imageName:(NSString*)imageName className:(NSString *)className
{
    BDChannel *column = [[self alloc] init];
    column.name = name;
    column.imageName = imageName;
    column.className = className;
    return column;

}

@end
