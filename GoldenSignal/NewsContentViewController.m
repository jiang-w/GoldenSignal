//
//  NewsContentViewController.m
//  GoldenSignal
//
//  Created by CBD on 7/3/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "NewsContentViewController.h"
#import "BDStockPoolInfoService.h"
#import <MBProgressHUD.h>

@interface NewsContentViewController ()
{
    BDStockPoolInfoService *_service;
    BDNews *_newsModel;//详情页面的Model数据
    long _connectId;
    
    BDNews *_newsModel2;//备用
    int _pageId;
}

@end

@implementation NewsContentViewController

- (instancetype)initWithModel:(NSObject *)model andId:(long)connectId andPageId:(int)pageId{
    self = [super init];
    if (self) {
        _newsModel2 = (BDNews *)model;
        _connectId = connectId;
        _pageId = pageId;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];

    [self performSelectorInBackground:@selector(getDetailRequestDataResource) withObject:nil];
//    [self getDetailRequestDataResource];
}


- (void)getDetailRequestDataResource{
    _newsModel = [BDNews new];
    _service = [BDStockPoolInfoService new];
    
    if (_connectId == 0) {
        [self showDetailInformationWithModel2:_newsModel2];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } else {
#pragma mark --异步加载
        _newsModel = [_service getOptionalNewsDetailById:_connectId andPageId:_pageId];
        // 相同于主线程中执行
        [self showDetailInformationWithModel:_newsModel];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
}




- (void)showDetailInformationWithModel:(BDNews *)model{
    
    self.titleLabel.text = model.title;
    if (model.date == 0 ) {
        self.dateLabel.text = 0;
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        if (_pageId == 1595) {
            formatter.dateFormat = @"yyyy-MM-dd";
        }
        self.dateLabel.text = [formatter stringFromDate:model.date];
    }
    
    self.mediaLabel.text = model.media;
    if (_pageId == 1595) {
        self.mediaLabel.text = model.companyName;
    }
    
    self.authorLabel.text = [model.author isEqualToString:@"--"] ? @"" : model.author;
    
    if (_connectId == 0) {
        self.desLabel.text = [NSString stringWithFormat:@"%@",model.title];
    } else {
        NSString *tempStr = model.content;
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<br />    " withString:@"\n\t"];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"    " withString:@"\n\t"];
        self.desLabel.text = tempStr;
    }
    
}

//要闻里的策略专用
- (void)showDetailInformationWithModel2:(BDNews *)model{
    
    self.titleLabel.text = model.title;
    if (model.date == 0 ) {
        self.dateLabel.text = 0;
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        self.dateLabel.text = [formatter stringFromDate:model.date];
    }
    
    self.mediaLabel.text = model.companyName;
    //    newsModel.abstract = [newsModel.ABST_SHT]
    self.authorLabel.text = [model.author isEqualToString:@"--"] ? @"" : model.author;
    
    //规范格式
    NSString *tempStr = model.ABST_SHT;
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<br />    " withString:@"\n\t"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"    " withString:@"\n\t"];
    self.desLabel.text = tempStr;
    
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
