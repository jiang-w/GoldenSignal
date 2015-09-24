//
//  F10ViewController.m
//  CBNAPP
//
//  Created by Frank on 15/1/12.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "F10ViewController.h"

@interface F10ViewController ()

@property(nonatomic, strong) UIWebView *webView;

@end

@implementation F10ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadF10PageWithSecuCode:(NSString *)code {
    if (self.webView == nil) {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.webView];
    }
    
    if (code) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://f10.chinabigdata.com/default.htm?c=%@&ql=1&istophide=1", [code lowercaseString]]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.webView loadRequest:request];
    }
}

@end
