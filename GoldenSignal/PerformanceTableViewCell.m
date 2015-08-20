//
//  PerformanceTableViewCell.m
//  
//
//  Created by CBD on 7/22/15.
//
//

#import "PerformanceTableViewCell.h"

@implementation PerformanceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


//计算文本label的高度
- (CGFloat)calcHightWithString:(UILabel *)lbl{
    return  [lbl.text boundingRectWithSize:CGSizeMake(lbl.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lbl.font} context:nil].size.height;
}



//公告的Cell
- (void)showGongGaoCellAndModel:(NSObject *)model{
    BDAnnouncementList *pModel = (BDAnnouncementList *)model;
    //日期 截取
    NSString *dateStr = [[NSString stringWithFormat:@"%@",pModel.date] substringToIndex:10];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"【%@】%@",dateStr,pModel.title]];
    [str addAttribute:NSForegroundColorAttributeName
                value:RGB(61, 177, 241)
                range:NSMakeRange(1, dateStr.length)];
    self.title1.attributedText = str;
    _cellRowHeight = [self calcHightWithString:self.title1] + 25;
    
    
//    [self setContentLabels:self.contentLabel andText:[NSString stringWithFormat:@"\t%@",pModel.title]];
}

//业绩的Cell
- (void)showYeJiCellAndModel:(NSObject *)model{
    BDPrompt *pModel = (BDPrompt *)model;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"【%@ %@】%@",pModel.trdCode,pModel.secuName,pModel.title]];
    [str addAttribute:NSForegroundColorAttributeName
                value:RGB(61, 177, 241)
                range:NSMakeRange(1, pModel.trdCode.length + 1 + pModel.secuName.length)];
    self.title1.attributedText = str;
    _cellRowHeight = [self calcHightWithString:self.title1] + 25;
    
//    [self setContentLabels:self.contentLabel andText:[NSString stringWithFormat:@"\t%@",pModel.title]];
}

//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText:(NSString *)text{
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    label.text = text;
    //设置label的最大行数
    label.numberOfLines = 9;
    CGSize size = CGSizeMake(label.frame.size.width, 2000);
    
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
