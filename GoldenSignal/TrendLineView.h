//
//  TrendLineView.h
//  CBNAPP
//
//  Created by Frank on 14/11/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendLineView : UIView
{
    CGRect lineFrame;
    CGRect volumeFrame;
}

@property(nonatomic, strong, readonly)NSString *code;

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code;

- (void)loadTrendLineDataWithNumberOfDays:(int)days;

@end
