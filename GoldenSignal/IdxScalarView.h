//
//  IdxQuoteView.h
//  GoldenSignal
//
//  Created by Frank on 15/6/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IdxScalarView : UIView

+ (IdxScalarView *)createView;

- (void)subscribeDataWithSecuCode:(NSString *)code;

@end
