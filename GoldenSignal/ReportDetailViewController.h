//
//  ReportDetailViewController.h
//  GoldenSignal
//
//  Created by CBD on 6/30/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDReport.h"

//typedef void(^CallBack)(NSString *obj);

@interface ReportDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contView;

@property (weak, nonatomic) IBOutlet UIScrollView *scroView;

@property (weak, nonatomic) IBOutlet UIView *secondView;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateAndAutLabel;

@property (weak, nonatomic) IBOutlet UILabel *rateAndPriLabel;

@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@property (nonatomic, copy) NSString *title;

//重写初始化方法
- (id)initWithModel:(NSObject *)model andConnectId:(long)connectId;
//赋值
- (void)showDetailInformationWithModel:(BDReport *)model;

//@property (nonatomic, copy) CallBack pushAction;


@end
