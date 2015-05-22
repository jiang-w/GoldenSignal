//
//  IndicatorsView.h
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndicatorsView : UIView

@property(nonatomic, strong, readonly)NSString *code;
@property(nonatomic, strong)IBOutlet UILabel *prevClose;
@property(nonatomic, strong)IBOutlet UILabel *open;
@property(nonatomic, strong)IBOutlet UILabel *high;
@property(nonatomic, strong)IBOutlet UILabel *low;
@property(nonatomic, strong)IBOutlet UILabel *now;
@property(nonatomic, strong)IBOutlet UILabel *change;
@property(nonatomic, strong)IBOutlet UILabel *changeRange;
@property(nonatomic, strong)IBOutlet UILabel *volumeSpread;
@property(nonatomic, strong)IBOutlet UILabel *volume;
@property(nonatomic, strong)IBOutlet UILabel *changeHandsRate;
@property(nonatomic, strong)IBOutlet UILabel *volRatio;
@property(nonatomic, strong)IBOutlet UILabel *amount;
@property(nonatomic, strong)IBOutlet UILabel *ttlAst;
@property(nonatomic, strong)IBOutlet UILabel *ttlAmountNtlc;
@property(nonatomic, strong)IBOutlet UIButton *favoriteButton;
@property(nonatomic, strong)IBOutlet UILabel *PEttm;
@property(nonatomic, strong)IBOutlet UILabel *Eps;

+ (IndicatorsView *)createView;

- (void)subscribeIndicatorsWithCode:(NSString *)code;

@end
