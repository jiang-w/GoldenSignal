//
//  StockViewController.h
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StkDetailViewController : UIViewController <UIScrollViewDelegate>

- (instancetype)initWithSecuCode:(NSString *)code;

@end
