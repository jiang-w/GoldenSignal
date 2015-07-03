//
//  BDKLine.h
//  CBNAPP
//
//  Created by Frank on 14/12/5.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDKLine : NSObject

@property(nonatomic, assign) unsigned int date;
@property(nonatomic, assign) double high;
@property(nonatomic, assign) double low;
@property(nonatomic, assign) double open;
@property(nonatomic, assign) double close;
@property(nonatomic, assign) unsigned long volume;

@end
