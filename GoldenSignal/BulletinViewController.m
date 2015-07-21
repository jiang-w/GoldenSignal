//
//  BulletinViewController.m
//  GoldenSignal
//
//  Created by CBD on 7/2/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "BulletinViewController.h"//公告详情
#import "BDStockPoolInfoService.h"
#import <MBProgressHUD.h>

@interface BulletinViewController ()<UIWebViewDelegate>
{
    BDStockPoolInfoService *_service;
    BDBulletin *_bulModel;//详情页面的Model数据
    
    long _bulletinId;//每条新闻对应的id
    
    BDBulletin *_bulModel2;//_bulletinId为空时调用传过来的model数据
}

@end

@implementation BulletinViewController


- (instancetype)initWithModel:(NSObject *)model andId:(long)cotentId{
    self = [super init];
    if (self) {
        _bulModel2 = (BDBulletin *)model;//传过来的Model；
        _bulletinId = cotentId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
    [self performSelectorInBackground:@selector(getDetailRequestDataResource) withObject:nil];
//    [self getDetailRequestDataResource];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)getDetailRequestDataResource{
    _bulModel = [BDBulletin new];
    _service = [BDStockPoolInfoService new];
    
    if (_bulletinId == 0) {
        [self showDetailInformationWithModel:_bulModel2];
        
    } else {
        _bulModel = [_service getBulletinDetailById:_bulletinId];
        [self showDetailInformationWithModel:_bulModel];
    }
}


- (void)showDetailInformationWithModel:(BDBulletin *)model{
    
    self.titleLabel.text = model.title;
    
    NSString *dateStr = [[NSString stringWithFormat:@"%@",model.date] substringToIndex:10];
    self.dateLabel.text = dateStr;
    
    self.readLabel.text = @"阅读PDF原文";
    

    if (_bulletinId == 0) {
        self.desLabel.text = [NSString stringWithFormat:@"\t%@",model.title];
    } else {
        self.desLabel.text = [NSString stringWithFormat:@"\t%@",model.content];
        DEBUGLog(@">>\n%@",model.content);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
