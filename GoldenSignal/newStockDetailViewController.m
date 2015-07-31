//
//  newStockDetailViewController.m
//  GoldenSignal
//
//  Created by CBD on 7/9/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "newStockDetailViewController.h"
#import "BDNewStockModel.h"
#import "BDImportService.h"

@interface newStockDetailViewController ()
{
//    long _stockCode;
    long _connectId;
    BDNewStockModel *_nsModel;
    BDImportService *_service;
}

@end

@implementation newStockDetailViewController


- (instancetype)initWithStockConnectId:(long)connectId{
    self = [super init];
    if (self) {
        _connectId = connectId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    NSCoder *code = [[NSCoder alloc]init];
    
    [self getDetailRequestDataResource];
}


- (void)getDetailRequestDataResource{
    _nsModel = [BDNewStockModel new];
    _service = [BDImportService new];
    
    _nsModel = [_service getImportNewsStockDetailWithId:_connectId andPageId:1591];
    [self showDetailInformationWithModel:_nsModel];
}


- (void)showDetailInformationWithModel:(BDNewStockModel *)model{
    _mediaLabel.text    = model.SECU_SHT;
    _codeIdLabel.text   = [NSString stringWithFormat:@"%@",model.SUB_CODE];
    _stockIdLabel.text  = [NSString stringWithFormat:@"%@",model.TRD_CODE];
    _starDateLabel.text = [NSString stringWithFormat:@"%@",model.SUB_BGN_DT_ON];
    
    _priceLabel.text  = [NSString stringWithFormat:@"%@",model.ISS_PRC];
    _diluteLabel.text = [NSString stringWithFormat:@"%@",model.PE_DIL];
    _grossLabel.text  = [NSString stringWithFormat:@"%@",model.ISS_SHR];
    _upperLabel.text  = [NSString stringWithFormat:@"%@",model.SUB_SHR_ON];
    
    _resultDateLabel.text = [NSString stringWithFormat:@"%@",model.ALOT_RSLT_NTC_DT];
    _marketTimeLabel.text = [NSString stringWithFormat:@"%@",model.LST_DT];
    _signRateLabel.text   = [NSString stringWithFormat:@"%@",model.SUCC_RAT_ON];
    _signNumbLabel.text   = model.ISS_ALOT_NO;
    
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
