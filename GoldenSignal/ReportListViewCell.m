//
//  ReportListViewCell.m
//  CBNAPP
//
//  Created by Frank on 14/12/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "ReportListViewCell.h"
#import "NSDate+Utility.h"

@implementation ReportListViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setReport:(BDReport *)report {
    _report = report;
    self.title.text = report.title;
    if ([report.date isSameDay:[NSDate date]]) {
        self.date.text= [report.date toString:@"hh:mm"];
    }
    else {
        self.date.text= [report.date toString:@"MM-dd"];
    }
}

@end
