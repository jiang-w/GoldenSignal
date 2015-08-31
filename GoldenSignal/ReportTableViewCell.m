//
//  ReportTableViewCell.m
//  GoldenSignal
//
//  Created by CBD on 6/23/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "ReportTableViewCell.h"

// 参数格式为：0xFFFFFF 颜色
#define kColorWithRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
                 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

@implementation ReportTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

//计算文本label的高度
- (CGFloat)calcHightWithString:(UILabel *)lbl{
    return  [lbl.text boundingRectWithSize:CGSizeMake(lbl.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lbl.font} context:nil].size.height;
}


//reportModel 研报信息 加载到Cell      //rModel.rating 买入、增持、谨慎增持、中性、推荐、强力推荐、
- (void)showCellAndReportModel:(BDReportList *)model{
    BDReportList *rModel = (BDReportList *)model;

//    NSString *titleStr = [NSMutableString stringWithFormat:@"%@ %@",rModel.rating,rModel.title];//新闻标题
    [self changeColorLabel:self.titleLabel RatingText:rModel.rating RateCode:rModel.RAT_CODE andOtherText:rModel.title];//传的新闻标题的label的两个字段
    _titleHeight = [self calcHightWithString:self.titleLabel];
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:rModel.date];
//    NSString *dateStr = [[NSString stringWithFormat:@"%@",rModel.date] substringToIndex:10];
    self.dataAndLabel.text = [NSString stringWithFormat:@"%@ %@ %@",dateStr,rModel.com,rModel.aut];
    
    [self setContentLabels:self.descriLabel andText:[NSString stringWithFormat:@"\t%@",rModel.abst]];//摘要描述 自适应布局
    _desHeight = [self calcHightWithString:self.descriLabel];
    
    
    if (rModel.targ_prc == 0.00) {
        self.priceLabel.hidden = YES;
        self.thirdView.frame = CGRectMake(self.thirdView.frame.origin.x, self.thirdView.frame.origin.y, self.thirdView.frame.size.width, 17);
        
//        CGRect frameDes = [self.descriLabel frame];
//        frameDes.origin.y = self.titleLabel.frame.size.height + self.dataAndLabel.frame.size.height +27;
        
        self.descriLabel.frame = CGRectMake(self.descriLabel.frame.origin.x, self.thirdView.frame.origin.y + 27, self.descriLabel.frame.size.width, self.descriLabel.frame.size.height);//描述label的坐标y上移
        
        _rowHeight = _titleHeight + self.thirdView.frame.size.height + _desHeight + 40;
        
    } else {
        self.priceLabel.hidden = NO;
        self.priceLabel.text = [NSString stringWithFormat:@"目标价: %.2lf",rModel.targ_prc];
        
        _rowHeight = _titleHeight + self.thirdView.frame.size.height + _desHeight + 40;
    }
}




//修改rating字体的颜色
- (void)changeColorLabel:(UILabel *)label RatingText:(NSString *)ratingText RateCode:(long)rateCode andOtherText:(NSString *)oText{
    NSString *sourceStr = [NSString stringWithFormat:@"%@ %@",ratingText,oText];
    
    UIColor *customColor = nil;
    
    if (rateCode == 10) {//10
        customColor = [UIColor redColor];
    }
    else if (rateCode == 20) {//20
        customColor = kColorWithRGB(0xFFC000);
    }
    else if (rateCode == 30) {//
        customColor = kColorWithRGB(0x0070C0);
    }
    else if (rateCode == 40) {//30
        customColor = kColorWithRGB(0x4F6228);
    }
    else if (rateCode == 50) {
        customColor = kColorWithRGB(0x00B050);
    }
    else {
        customColor = [UIColor blackColor];
        sourceStr = [sourceStr substringFromIndex:1];
    }
    
    NSMutableAttributedString *strRat = [[NSMutableAttributedString alloc]initWithString:sourceStr];
    [strRat addAttribute:NSForegroundColorAttributeName
                   value:customColor
                   range:NSMakeRange(0, ratingText.length)];
    
    
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    label.attributedText = strRat;
    //设置label的最大行数
    label.numberOfLines = 6;
    CGSize size = CGSizeMake(300, 1000);
    
    CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    //计算出自适应的高度
    frame.size.height = labelSize.height;
    self.frame = frame;
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
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    
    //计算出自适应的高度
    frame.size.height = labelSize.height;
    
    self.frame = frame;
}













#if 0
//赋值 and 自动换行,计算出cell的高度
- (void)setContentLabels:(UILabel *)label andText2:(NSString *)text{
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    label.text = text;
    //设置label的最大行数
    label.numberOfLines = 6;
    CGSize size = CGSizeMake(300, 1000);
    
    CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    
    //计算出自适应的高度
    frame.size.height = labelSize.height;
    
    self.frame = frame;
}
#endif

//打印的信息
- (void)nslog{
    //研报：NSLog(@"->%ld,%@,%@,%@,%@,%@,%lf,%@,%ld",pModel.innerId,pModel.title,pModel.date ,pModel.rating ,pModel.com ,pModel.aut ,pModel.targ_prc ,pModel.abst,pModel.sn);
    //1127139911,蓝色光标(300058)布局移动广告业务 营销产业王者归来,2015-06-09 16:00:00 +0000,强烈推荐,招商证券,王京乐,36.000000,移动端+大数据不断补强，占据移动端市场第一。亿动是移动广告业务中的领先企业，在移动广,0
    
    //新闻：NSLog(@"->%ld,%@,%@, %@, %@,%@, %@, %@,%@",pModel.innerId,pModel.title,pModel.date, pModel.abstract, pModel.content,pModel.author, pModel.media,pModel.imageUrl,pModel.labels);
    //1132285740, 标的涉诉致大连控股(600747)重组失败, 2015-06-16 16:00:00 +0000,
    //大连控股(600747)重组一波三折，最终因大股东资金往来纠纷涉及重组标的，公司决定,
    //(null),(null),
    //中国证券网,(null),()
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
