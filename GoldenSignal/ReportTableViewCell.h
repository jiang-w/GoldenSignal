//
//  ReportTableViewCell.h
//  GoldenSignal
//
//  Created by CBD on 6/23/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
//两个Model
#import "BDReport.h"
#import "BDNews.h"

@interface ReportTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIView *thirdView;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UILabel *dataAndLabel;


@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriLabel;


- (void)showCellAndReportModel:(BDReport *)model;

//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText:(NSString *)text;


@property (nonatomic,assign) CGFloat titleHeight;
@property (nonatomic,assign) CGFloat desHeight;

@property (nonatomic,assign) CGFloat rowHeight;

@end
