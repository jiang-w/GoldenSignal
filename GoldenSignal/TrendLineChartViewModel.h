//
//  TrendLineChartViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendLineChartViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, copy, readonly) NSString *code;

/**
 *  前收价
 */
@property(nonatomic, assign, readonly) float prevClose;

/**
 *  是否已经完成初始化(加载完历史走势数据)
 */
@property(nonatomic, assign, readonly)BOOL initialized;


- (void)loadTrendLineWithSecuCode:(NSString *)code ForDays:(int)days andInterval:(int)interval;

@end
