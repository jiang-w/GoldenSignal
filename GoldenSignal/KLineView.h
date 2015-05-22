//
//  KLineView.h
//  CBNAPP
//
//  Created by Frank on 14/12/3.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLineView : UIView
{
    UILabel *xLine;  //x线
    UILabel *yLine;  //y线
    UILabel *xLabel; //x数值
    UILabel *yLabel; //y数值
    
    CGRect lineFrame;
    CGRect volumeFrame;
}

@property(nonatomic, strong, readonly)NSString *code;

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code;

- (void)loadKLineDataWithType:(KLineType)type andNumber:(int)number;

@end
