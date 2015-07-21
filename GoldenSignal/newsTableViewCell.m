//
//  newsTableViewCell.m
//  GoldenSignal
//
//  Created by CBD on 6/24/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "newsTableViewCell.h"

@implementation newsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


//newsModel 新闻信息 加载到Cell
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
    
    self.dataAndLabel.text = [NSString stringWithFormat:@"%@%@",dateStr,newsModel.media];
    
    
//    self.dataAndLabel.text =[NSString stringWithFormat:@"%@",newsModel.date];
    [self setContentLabels:self.newsDesLabel andText:[NSString stringWithFormat:@"\t%@",newsModel.abstract]];//摘要
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
