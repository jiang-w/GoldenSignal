//
//  NewsListViewCell.h
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsListViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UILabel *title;
@property(nonatomic,strong) IBOutlet UILabel *date;

@property (nonatomic,setter = setNews:) BDNews *news;

@end
