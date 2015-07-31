//
//  newStockDetailViewController.h
//  GoldenSignal
//
//  Created by CBD on 7/9/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newStockDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *secondView;


@property (weak, nonatomic) IBOutlet UILabel *mediaLabel;//股票简称
@property (weak, nonatomic) IBOutlet UILabel *codeIdLabel;//申购代码
@property (weak, nonatomic) IBOutlet UILabel *stockIdLabel;//股票代码
@property (weak, nonatomic) IBOutlet UILabel *starDateLabel;//申购日期

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;//发行价格
@property (weak, nonatomic) IBOutlet UILabel *diluteLabel;//发行市盈率
@property (weak, nonatomic) IBOutlet UILabel *grossLabel;//发行总数
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;//申购上限

@property (weak, nonatomic) IBOutlet UILabel *resultDateLabel;//中签公布日
@property (weak, nonatomic) IBOutlet UILabel *marketTimeLabel;//上市日期
@property (weak, nonatomic) IBOutlet UILabel *signRateLabel;//网上中签率
@property (weak, nonatomic) IBOutlet UILabel *signNumbLabel;//网上中签号

//股票代码的Code
- (instancetype)initWithStockConnectId:(long)connectId;

@property (nonatomic, assign) long connectId;

@end
