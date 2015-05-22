//
//  BDColumn.h
//  CBNAPP
//
//  Created by Frank on 14-9-1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDChannel : NSObject

// 栏目名称
@property (nonatomic,copy)NSString *name;
// 栏目图片名称
@property (nonatomic,copy)NSString *imageName;
// 栏目对应的控制器的类名
@property (nonatomic,copy)NSString *className;

+ (BDChannel *)createWithName:(NSString *)name imageName:(NSString*)imageName className:(NSString *)className;

@end
