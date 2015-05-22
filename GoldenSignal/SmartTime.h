//
//  BDTime.h
//  CBNAPP
//
//  Created by Frank on 14/12/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartTime : NSObject

@property(nonatomic, assign)NSInteger hour;
@property(nonatomic, assign)NSInteger minute;
@property(nonatomic, assign)NSInteger second;

- (id)initWithHour:(NSInteger)hour andMinute:(NSInteger)minute andSecond:(NSInteger)second;

- (SmartTime *)addHours:(NSInteger)value;

- (SmartTime *)addMinutes:(NSInteger)value;

- (SmartTime *)addSeconds:(NSInteger)value;

+ (SmartTime *)time;

- (NSComparisonResult)compare:(SmartTime *)time;

@end
