//
//  BDTrendLine.h
//  CBNAPP
//
//  Created by Frank on 14/12/9.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDTrendLine : NSObject

@property(nonatomic, assign) int date;
@property(nonatomic, assign) int time;
@property(nonatomic, assign) float price;
@property(nonatomic, assign) double amount;
@property(nonatomic, assign) unsigned int volume;

@end
