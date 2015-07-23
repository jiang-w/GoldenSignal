//
//  ImportsTableViewCell.h
//  GoldenSignal
//
//  Created by CBD on 7/6/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;//摘要


- (void)showCellAndNewsModel:(NSObject *)model;
//策略的数据
- (void)showCellAndStrategyNewsModel:(NSObject *)model;

//赋值 and 自动换行,计算出cell的高度
//- (void)setContentLabels:(UILabel *)label andText:(NSString *)text;

@property (nonatomic,assign)CGFloat titleHeight;
@property (nonatomic,assign)CGFloat desHeight;


@end
