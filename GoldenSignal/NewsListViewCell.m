//
//  NewsListViewCell.m
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "NewsListViewCell.h"
#import "NSDate+Utility.h"

@implementation NewsListViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNews:(BDNewsList *)news {
    _news = news;
    self.title.text = news.title;
//    self.date.text= [news.date toString:@"yyyy-MM-dd hh:mm"];
    if ([news.date isSameDay:[NSDate date]]) {
        self.date.text= [news.date toString:@"hh:mm"];
    }
    else {
        self.date.text= [news.date toString:@"MM-dd"];
    }
}

@end
