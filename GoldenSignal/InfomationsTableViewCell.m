//
//  InfomationsTableViewCell.m
//  GoldenSignal
//
//  Created by CBD on 6/19/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "InfomationsTableViewCell.h"


@implementation InfomationsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

//计算文本label的高度
- (CGFloat)calcHightWithString:(UILabel *)lbl{
    return  [lbl.text boundingRectWithSize:CGSizeMake(lbl.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lbl.font} context:nil].size.height;
}


//提示的Cell
- (void)showTiShiCellAndModel:(NSObject *)model{
    BDPrompt *pModel = (BDPrompt *)model;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"【%@】%@",pModel.secuName , pModel.title]];
    [str addAttribute:NSForegroundColorAttributeName
                value:RGB(61, 177, 241)
                range:NSMakeRange(1, pModel.secuName.length)];
    self.title1.attributedText = str;
    _titleLabelHeight = [self calcHightWithString:self.title1];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:pModel.date];
    self.dateLabel.text = [dateStr substringToIndex:10];
}



#if 0
//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText:(NSString *)text{
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    label.text = text;
    //设置label的最大行数
    label.numberOfLines = 10;
    CGSize size = CGSizeMake(300, 1000);
    
    CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    //    [boundingRectWithSize:options:attributes:context:]
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    
    //计算出自适应的高度
    frame.size.height = labelSize.height;
    
    self.frame = frame;
}
#endif

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
