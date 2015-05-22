//
//  BDKLine.h
//  CBNAPP
//
//  Created by Frank on 14/12/5.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDKLine : NSObject

@property(nonatomic, assign) int date;
@property(nonatomic, assign) float high;
@property(nonatomic, assign) float low;
@property(nonatomic, assign) float open;
@property(nonatomic, assign) float close;
@property(nonatomic, assign) unsigned int volume;

@end
