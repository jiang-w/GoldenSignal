//
//  newsTableViewCell.h
//  GoldenSignal
//
//  Created by CBD on 6/24/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *dataAndLabel;

@property (weak, nonatomic) IBOutlet UILabel *newsDesLabel;


//- (void)showCellAndReportModel:(BDNews *)model;
- (void)showCellAndNewsModel:(NSObject *)model;

//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText:(NSString *)text;






@end
