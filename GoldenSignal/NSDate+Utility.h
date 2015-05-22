//
//  NSDate+Utility.h
//  CBNAPP
//
//  Created by Frank on 14-8-21.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utility)

- (NSString *)toString:(NSString *)format;

- (NSDate *)addDays:(int)value;

- (NSInteger)getYear;

- (NSInteger)getMonth;

- (NSInteger)getDay;

- (BOOL)isSameDay:(NSDate *)date;

@end
