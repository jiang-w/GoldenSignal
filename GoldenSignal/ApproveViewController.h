//
//  ApproveViewController.h
//  GoldenSignal
//
//  Created by CBD on 15/8/13.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApproveViewController : UIViewController

@property(nonatomic, strong) NSString *BD_CODE;
@property (nonatomic,strong) UIView *baseView;

@property (nonatomic, strong) NSMutableArray *xLabels;
@property (nonatomic, assign) CGFloat xLabelWidth;

@end
