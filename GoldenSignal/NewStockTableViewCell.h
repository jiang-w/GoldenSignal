//
//  NewStockTableViewCell.h
//  GoldenSignal
//
//  Created by CBD on 7/8/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDNewStockModel.h"

@interface NewStockTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contenVIew;
@property (weak, nonatomic) IBOutlet UIView *baseView;


@property (weak, nonatomic) IBOutlet UILabel *medialabel;
@property (weak, nonatomic) IBOutlet UILabel *codeIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
/**
 *  摊薄PE
 */
@property (weak, nonatomic) IBOutlet UILabel *diluteLabel;
/**
 *  上限
 */
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;
/**
 *  总量
 */
@property (weak, nonatomic) IBOutlet UILabel *grossLabel;

/**
 *  结果日
 */
@property (weak, nonatomic) IBOutlet UILabel *resultDataLabel;



- (void)showNewStockCellAndModel:(NSObject *)model;




@end
