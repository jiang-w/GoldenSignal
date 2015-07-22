//
//  QuoteViewCell.h
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StkQuoteViewCell : UITableViewCell

@property(nonatomic, weak)IBOutlet UILabel *name;
@property(nonatomic, weak)IBOutlet UILabel *trdCode;
@property(nonatomic, weak)IBOutlet UILabel *now;
@property(nonatomic, weak)IBOutlet UILabel *changeRange;
@property(nonatomic, weak)IBOutlet UILabel *volume;
@property(nonatomic, weak)IBOutlet UILabel *ttlAmount;
@property(nonatomic, weak)IBOutlet UILabel *pettm;
@property(nonatomic, weak)IBOutlet UIView *trendView;
@property(nonatomic, weak)IBOutlet UIView *kLineView;
@property(nonatomic, weak)IBOutlet UILabel *level;
@property(nonatomic, weak)IBOutlet UILabel *label;
@property(nonatomic, weak)IBOutlet UILabel *date;

@property(nonatomic, setter = setCode:) NSString *code;

@end
