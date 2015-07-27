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

//计算文本label的高度
- (CGFloat)calcHightWithString:(UILabel *)lbl{
    return  [lbl.text boundingRectWithSize:CGSizeMake(lbl.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lbl.font} context:nil].size.height;
}


//newsModel 要闻 加载到Cell
- (void)showCellAndNewsModel:(NSObject *)model{
    BDNewsList *newsModel = (BDNewsList *)model;
    self.titleLabel.text =  newsModel.title;
    _titleHeight = [self calcHightWithString:self.titleLabel];
    
    //时间
    NSString *dateStr = nil;
    if (newsModel.date == 0 ) {
        dateStr = @"";
    } else {
        dateStr = [[NSString stringWithFormat:@"%@",newsModel.date] substringToIndex:16];
        dateStr = [NSString stringWithFormat:@"%@ ",dateStr];
    }
    self.dateLabel.text = dateStr;
    self.desLabel.text = [NSString stringWithFormat:@"\t%@",newsModel.abstract];
    _desHeight = [self calcHightWithString:self.desLabel];
}

//策略的数据
- (void)showCellAndStrategyNewsModel:(NSObject *)model{
    BDNewsList *newsModel = (BDNewsList *)model;
    
    self.titleLabel.text = newsModel.title;//新闻标题内容
    _titleHeight = [self calcHightWithString:self.titleLabel];
    
    //时间
    NSString *dateStr = nil;
    if (newsModel.date == 0 ) {
        dateStr = @"";
    } else {
        dateStr = [[NSString stringWithFormat:@"%@",newsModel.date] substringToIndex:10];
        dateStr = [NSString stringWithFormat:@"%@ ",dateStr];
    }
    
    newsModel.author = [newsModel.author isEqualToString:@"--"] ? @"" : newsModel.author;
    self.dateLabel.text = [NSString stringWithFormat:@"%@%@ %@",dateStr, newsModel.companyName, newsModel.author];
    
    self.desLabel.text = [NSString stringWithFormat:@"\t%@",newsModel.abstract];
    _desHeight = [self calcHightWithString:self.desLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}





#if 0
//-(CGFloat)calulateHeightWithtTitle:(NSString*)title desrip:(NSString*)descrip
- (CGFloat)testLabel:(UILabel *)label andText:(NSString *)text{
    //这里非常重要
    CGFloat preMaxWaith =[UIScreen mainScreen].bounds.size.width-20;
    
    [label setPreferredMaxLayoutWidth:preMaxWaith];
    
    
    [label setText:text];
    //这也很重要
    [label layoutIfNeeded];
    
    [self.contentView layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //加1是关键
    return size.height+1.0f;
}



//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText:(NSString *)text{
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    label.text = text;
    //设置label的最大行数
//    label.numberOfLines = 0;
//    CGSize size = CGSizeMake(self.secondView.frame.size.width-20, 1000);
    
//    CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
//    CGRect fram = [label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    CGSize labelSize = [label.text boundingRectWithSize:CGSizeMake(label.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size;

    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    //计算出自适应的高度
    frame.size.height = labelSize.height;
    
    self.frame = frame;
}
#endif


@end
