//
//  IdxTrendView.h
//  GoldenSignal
//
//  Created by Frank on 15/6/3.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteHomeTrendView : UIView

@property (weak, nonatomic) IBOutlet UIView *head;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UILabel *now;
@property (weak, nonatomic) IBOutlet UILabel *change;
@property (weak, nonatomic) IBOutlet UILabel *changeRange;
@property (weak, nonatomic) IBOutlet UILabel *open;
@property (weak, nonatomic) IBOutlet UILabel *volume;
@property (weak, nonatomic) IBOutlet UIView *chart;


+ (QuoteHomeTrendView *)createViewWithIdxCode:(NSString *)code;

@end
