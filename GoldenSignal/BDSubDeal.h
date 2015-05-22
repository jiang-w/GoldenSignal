//
//  BDSubDeal.h
//  CBNAPP
//
//  Created by Frank on 14/12/11.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSubDeal : NSObject

@property(nonatomic, assign) int date;
@property(nonatomic, assign) int time;
@property(nonatomic, assign) float price;
@property(nonatomic, assign) float change;
@property(nonatomic, assign) int volumeSpread;
@property(nonatomic, assign) int tradeDirection;
@property(nonatomic, assign) int positionSpread;

@end
