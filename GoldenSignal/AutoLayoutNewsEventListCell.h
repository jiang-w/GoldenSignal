//
//  AutoLayoutNewsListCell.h
//  GoldenSignal
//
//  Created by Frank on 15/5/15.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoLayoutNewsEventListCell : UITableViewCell
{
    UIView *container;
    UILabel *title;
    UILabel *date;
    UILabel *detail;
    UIView *tagContainer;
}

@property (nonatomic,setter = setNews:) BDNews *news;

@end
