//
//  ReportListViewCell.h
//  CBNAPP
//
//  Created by Frank on 14/12/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportListViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UILabel *title;
@property(nonatomic,strong) IBOutlet UILabel *date;

@property (nonatomic,setter = setReport:) BDReportList *report;

@end
