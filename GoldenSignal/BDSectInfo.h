//
//  BDSectInfo.h
//  GoldenSignal
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSectInfo : NSObject

@property(nonatomic, assign)long sectId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *typCode;
@property(nonatomic, strong)NSString *typName;
@property(nonatomic, assign)int sort;

@end
