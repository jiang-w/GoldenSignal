//
//  LeftTableViewController.h
//  CBNAPP
//
//  Created by Frank on 14-9-1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRevealControllerProperty.h"
#import "BDChannel.h"

@interface SideMenuViewController : UITableViewController <IRevealControllerProperty>

// 栏目数组,保存的是左边栏目列表中的所有栏目对象
@property(nonatomic,strong) NSArray *columnArray;


@end
