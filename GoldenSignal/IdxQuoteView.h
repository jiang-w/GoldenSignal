//
//  IdxQuoteView.h
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IdxQuoteView : UIView

@property(nonatomic, strong, readonly) NSString *code;
@property (weak, nonatomic) IBOutlet UILabel *now;
@property (weak, nonatomic) IBOutlet UILabel *change;
@property (weak, nonatomic) IBOutlet UILabel *changeRange;
@property (weak, nonatomic) IBOutlet UILabel *open;
@property (weak, nonatomic) IBOutlet UILabel *prevClose;
@property (weak, nonatomic) IBOutlet UILabel *high;
@property (weak, nonatomic) IBOutlet UILabel *low;
@property (weak, nonatomic) IBOutlet UILabel *volume;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *amplitude;
@property (weak, nonatomic) IBOutlet UILabel *volumeSpread;
@property (weak, nonatomic) IBOutlet UILabel *upCount;
@property (weak, nonatomic) IBOutlet UILabel *downCount;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

+ (IdxQuoteView *)createView;
- (void)loadDataWithIdxCode:(NSString *)code;

@end
