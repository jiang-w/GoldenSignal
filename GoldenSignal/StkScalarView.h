//
//  StkScalarView.h
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StkScalarView : UIView

@property(nonatomic, strong, readonly)NSString *code;
@property(nonatomic, weak) IBOutlet UILabel *prevClose;
@property(nonatomic, weak) IBOutlet UILabel *open;
@property(nonatomic, weak) IBOutlet UILabel *high;
@property(nonatomic, weak) IBOutlet UILabel *low;
@property(nonatomic, weak) IBOutlet UILabel *now;
@property(nonatomic, weak) IBOutlet UILabel *change;
@property(nonatomic, weak) IBOutlet UILabel *changeRange;
@property(nonatomic, weak) IBOutlet UILabel *volumeSpread;
@property(nonatomic, weak) IBOutlet UILabel *volume;
@property(nonatomic, weak) IBOutlet UILabel *changeHandsRate;
@property(nonatomic, weak) IBOutlet UILabel *volRatio;
@property(nonatomic, weak) IBOutlet UILabel *amount;
@property(nonatomic, weak) IBOutlet UILabel *ttlAst;
@property(nonatomic, weak) IBOutlet UILabel *ttlAmountNtlc;
@property(nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property(nonatomic, weak) IBOutlet UILabel *PEttm;
@property(nonatomic, weak) IBOutlet UILabel *Eps;

+ (StkScalarView *)createView;

- (void)loadDataWithCode:(NSString *)code;

@end
