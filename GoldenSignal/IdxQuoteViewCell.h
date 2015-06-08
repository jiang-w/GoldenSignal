//
//  IdxQuoteViewCell.h
//  GoldenSignal
//
//  Created by Frank on 15/6/8.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IdxQuoteViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *trdCode;
@property (weak, nonatomic) IBOutlet UILabel *changeRange;
@property (strong, nonatomic) IBOutlet UIView *trendView;
@property (strong, nonatomic) IBOutlet UIView *kLineView;
@property (weak, nonatomic) IBOutlet UILabel *now;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *volume;
@property (weak, nonatomic) IBOutlet UILabel *upCount;
@property (weak, nonatomic) IBOutlet UILabel *sameCount;
@property (weak, nonatomic) IBOutlet UILabel *downCount;

@property(nonatomic, setter = setCode:) NSString *code;

@end
