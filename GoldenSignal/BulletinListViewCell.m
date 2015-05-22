//
//  BulletinListViewCell.m
//  CBNAPP
//
//  Created by Frank on 14/12/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BulletinListViewCell.h"
#import "NSDate+Utility.h"

@implementation BulletinListViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBulletin:(BDBulletin *)bulletin {
    _bulletin = bulletin;
    self.title.text = bulletin.title;
    if ([bulletin.date isSameDay:[NSDate date]]) {
        self.date.text= [bulletin.date toString:@"hh:mm"];
    }
    else {
        self.date.text= [bulletin.date toString:@"MM-dd"];
    }
}

@end
