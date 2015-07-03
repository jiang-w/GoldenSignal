//
//  KLineChartViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/7/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLineChartViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, strong, readonly) NSString *code;

/**
 *  走势线
 */
@property(nonatomic, strong, readonly) NSMutableArray *lines;


- (void)loadDataWithSecuCode:(NSString *)code forType:(KLineType)type andNumber:(NSUInteger)number;

@end
