//
//  ReportDetailViewController.m
//  GoldenSignal
//
//  Created by CBD on 6/30/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "ReportDetailViewController.h"//研报详情
#import "BDStockPoolInfoService.h"
#import "BDReport.h"
#import <MBProgressHUD.h>

#define DFMainScreen [[UIScreen mainScreen] bounds]
// 参数格式为：0xFFFFFF
#define kColorWithRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
                    blue :((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]



@interface ReportDetailViewController ()<UIScrollViewDelegate>
{
    BDStockPoolInfoService *_service;
    BDReport *_reModel;//详情页面的Model数据
    BDReport *_reModel2;//为空时调用传过来的model数据
    long _connectId;
}

@end

@implementation ReportDetailViewController

- (id)initWithModel:(NSObject *)model andConnectId:(long)connectId{
    self = [super init];
    if (self) {
        _reModel2 = (BDReport *)model;
        _connectId = connectId;
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
    _reModel = [BDReport new];
    _service = [BDStockPoolInfoService new];
    
    if (_connectId == 0) {
        [self showDetailInformationWithModel:_reModel2];
        
    } else {
        _reModel = [_service getReportDetailById:_connectId];
        [self showDetailInformationWithModel:_reModel];
    }
}


- (void)showDetailInformationWithModel:(BDReport *)model{
    
    self.titleLabel.text = model.title;
    
    NSString *dateStr = [[NSString stringWithFormat:@"%@",model.date] substringToIndex:10];
    self.dateAndAutLabel.text = [NSString stringWithFormat:@"%@  %@ %@",dateStr,model.com,model.aut];
    
    self.rateAndPriLabel.attributedText =[self changeColorRatingText:model.rating RateCode:model.RAT_CODE andOtherText:model.targ_prc];
    
    
    NSString *tempStr = model.CONT;
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<br />    " withString:@"\n\t"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"    " withString:@"\t"];
    
    self.desLabel.text = tempStr;
}

//修改rating字体的颜色
- (NSMutableAttributedString *)changeColorRatingText:(NSString *)ratingText RateCode:(long)rateCode andOtherText:(float)oText{
    NSString *ratStr = ([ratingText isEqualToString:@""]) ? @"--" : [NSString stringWithFormat:@"%@",ratingText];
    //价格
    NSString *priStr = (oText == 0.00) ? @"--" : [NSString stringWithFormat:@"%.2lf",oText];
    NSString *sourceStr = [NSString stringWithFormat:@" 评级：%@  目标价：%@",ratStr,priStr];
    
    UIColor *customColor = nil;
    if (rateCode == 10) {
        customColor = [UIColor redColor];
    }
    else if (rateCode == 20) {
        customColor = kColorWithRGB(0xFFC000);
    }
    else if (rateCode == 30) {
        customColor = kColorWithRGB(0x0070C0);
    }
    else if (rateCode == 40) {
        customColor = kColorWithRGB(0x4F6228);
    }
    else if (rateCode == 50) {
        customColor = kColorWithRGB(0x00B050);
    }
    else {
        customColor = [UIColor blackColor];
        sourceStr = [sourceStr substringFromIndex:1];
    }
    
    NSMutableAttributedString *strRat = [[NSMutableAttributedString alloc]initWithString:sourceStr];
    [strRat addAttribute:NSForegroundColorAttributeName
                   value:customColor
                   range:NSMakeRange(4, ratingText.length)];
    return strRat;
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
