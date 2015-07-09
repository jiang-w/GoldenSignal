//
//  LiteStkQuoteViewCell.h
//  GoldenSignal
//
//  Created by Frank on 15/7/8.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *trdCode;
@property (weak, nonatomic) IBOutlet UILabel *changeRange;
@property (weak, nonatomic) IBOutlet UILabel *now;
@property (weak, nonatomic) IBOutlet UILabel *change;

@property(nonatomic, setter = setCode:) NSString *code;

@end
