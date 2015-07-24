//
//  ReportDetailViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/7/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportDetailViewController1  : UIViewController<UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;

@property(nonatomic, assign) long contentId;

@end
