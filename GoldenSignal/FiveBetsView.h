//
//  FiveBetsView.h
//  CBNAPP
//
//  Created by Frank on 14/11/26.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiveBetsView : UIView

@property(nonatomic, strong, readonly)NSString *code;

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code;

@end
