//
//  InfomationsTableViewCell.h
//  GoldenSignal
//
//  Created by CBD on 6/19/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDPrompt.h"

@interface InfomationsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *title1;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


- (void)showCellAndModel:(NSObject *)model;
- (void)showGongGaoCellAndModel:(NSObject *)model;

//赋值 and 自动换行,计算出cell的高度
-(void)setContentLabels:(UILabel *)label andText:(NSString *)text;


- (void)showGongGaoCellAndModel2:(NSObject *)model;

@end
