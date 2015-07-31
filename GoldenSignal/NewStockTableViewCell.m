//
//  NewStockTableViewCell.m
//  GoldenSignal
//
//  Created by CBD on 7/8/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "NewStockTableViewCell.h"
#import "NSDate+Utility.h"

@implementation NewStockTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)showNewStockCellAndModel:(NSObject *)model{
    
    BDNewStockModel *nsModel = (BDNewStockModel *)model;
    
    _medialabel.text  = nsModel.SECU_SHT;
    _codeIdLabel.text = nsModel.TRD_CODE;
    
    _priceLabel.text  = nsModel.ISS_PRC;
    _diluteLabel.text = nsModel.PE_DIL;
    
    _upperLabel.text  = nsModel.SUB_SHR_ON;
    _grossLabel.text  = nsModel.ISS_SHR;
    
    _resultDataLabel.text = [nsModel.ALOT_RSLT_NTC_DT1 toString:@"MM-dd"];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
