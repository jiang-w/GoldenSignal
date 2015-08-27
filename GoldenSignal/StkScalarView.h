//
//  StkScalarView.h
//  CBNAPP
//
//  Created by Frank on 14/12/1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StkScalarViewModel.h"

@interface StkScalarView : UIView

@property(nonatomic, strong) StkScalarViewModel *viewModel;

+ (StkScalarView *)createView;

- (void)loadDataWithCode:(NSString *)code;

@end
