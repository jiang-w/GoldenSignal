//
//  ImportsTableViewCell.m
//  GoldenSignal
//
//  Created by CBD on 7/6/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "ImportsTableViewCell.h"

@implementation ImportsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


//newsModel 要闻 加载到Cell
- (void)showCellAndNewsModel:(NSObject *)model{
    BDNews *newsModel = (BDNews *)model;
    [self setContentLabels:self.titleLabel andText:newsModel.title];//新闻标题内容
    //时间
    NSString *dateStr = nil;
    if (newsModel.date == 0 ) {
        dateStr = @"";
    } else {
        dateStr = [[NSString stringWithFormat:@"%@",newsModel.date] substringToIndex:16];
        dateStr = [NSString stringWithFormat:@"%@ ",dateStr];
    }
    self.dateLabel.text = dateStr;
    
    [self setContentLabels:self.desLabel andText:[NSString stringWithFormat:@"\t%@",newsModel.abstract]];//摘要
}

//策略的数据
- (void)showCellAndStrategyNewsModel:(NSObject *)model{
    BDNews *newsModel = (BDNews *)model;
    [self setContentLabels:self.titleLabel andText:newsModel.title];//新闻标题内容
    //时间
    NSString *dateStr = nil;
    if (newsModel.date == 0 ) {
        dateStr = @"";
    } else {
        dateStr = [[NSString stringWithFormat:@"%@",newsModel.date] substringToIndex:10];
        dateStr = [NSString stringWithFormat:@"%@ ",dateStr];
    }
    
    newsModel.author = [newsModel.author isEqualToString:@"--"] ? @"" : newsModel.author;
    self.dateLabel.text = [NSString stringWithFormat:@"%@%@ %@",dateStr,newsModel.companyName,newsModel.author];
    
    
    [self setContentLabels:self.desLabel andText:[NSString stringWithFormat:@"\t%@",newsModel.abstract]];//摘要
}


//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText:(NSString *)text{
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    label.text = text;
    //设置label的最大行数
    label.numberOfLines = 6;
    CGSize size = CGSizeMake(300, 1000);
    
    CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
//    [boundingRectWithSize:options:attributes:context:]
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    
    //计算出自适应的高度
    frame.size.height = labelSize.height;
    
    self.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
