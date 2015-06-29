//
//  SubDealViewModel.h
//  CBNAPP
//
//  Created by Frank on 14/12/11.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubDealViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, strong, readonly) NSString *code;

/**
 *  交易明细数组
 */
@property(nonatomic, strong, readonly) NSMutableArray *dealArray;

/**
 *  前收价
 */
@property(nonatomic, assign, readonly) double prevClose;


- (id)initWithCode:(NSString *)code;

@end
