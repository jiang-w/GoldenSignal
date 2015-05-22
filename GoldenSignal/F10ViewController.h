//
//  F10ViewController.h
//  CBNAPP
//
//  Created by Frank on 15/1/12.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface F10ViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic, strong) IBOutlet UIWebView *webView;

@property(nonatomic, strong) NSString *code;

@end
