//
//  SubDealView.h
//  CBNAPP
//
//  Created by Frank on 14/12/11.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubDealView : UIView

@property(nonatomic, strong, readonly)NSString *code;

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code;

@end
