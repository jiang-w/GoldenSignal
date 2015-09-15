//
//  StkScalarView.h
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StkScalarView : UIView

+ (StkScalarView *)createView;

- (void)subscribeDataWithSecuCode:(NSString *)code;

@end
