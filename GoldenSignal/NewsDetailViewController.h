//
//  NewsDetailViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/7/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDetailViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;

@property(nonatomic, assign) long contentId;

@end
