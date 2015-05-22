//
//  IRevealControllerProperty.h
//  CBNAPP
//
//  Created by Frank on 14-9-29.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 具有revealController(侧开菜单控制器)属性的接口.
@protocol IRevealControllerProperty <NSObject>

/// 侧开菜单控制器.
@property (nonatomic,weak) GHRevealViewController* revealController;

@end
