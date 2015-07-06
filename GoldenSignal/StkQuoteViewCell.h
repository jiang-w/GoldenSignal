//
//  QuoteViewCell.h
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StkQuoteViewCell : UITableViewCell

@property(nonatomic, strong)IBOutlet UILabel *name;
@property(nonatomic, strong)IBOutlet UILabel *trdCode;
@property(nonatomic, strong)IBOutlet UILabel *now;
@property(nonatomic, strong)IBOutlet UILabel *changeRange;
@property(nonatomic, strong)IBOutlet UILabel *volume;
@property(nonatomic, strong)IBOutlet UILabel *ttlAmount;
@property(nonatomic, strong)IBOutlet UILabel *pettm;
@property(nonatomic, strong)IBOutlet UIView *trendView;
@property(nonatomic, strong)IBOutlet UIView *kLineView;
@property(nonatomic, strong)IBOutlet UILabel *level;
@property(nonatomic, strong)IBOutlet UILabel *label;
@property(nonatomic, strong)IBOutlet UILabel *date;

@property(nonatomic, setter = setCode:) NSString *code;

@end
