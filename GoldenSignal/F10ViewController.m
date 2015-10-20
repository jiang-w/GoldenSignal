//
//  F10ViewController.m
//  CBNAPP
//
//  Created by Frank on 15/1/12.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "F10ViewController.h"
#import <Masonry.h>

@interface F10ViewController ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation F10ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.titleView = self.titleLabel;
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.titleLabel sizeToFit];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

- (void)loadF10PageWithSecuCode:(NSString *)code {
    if (code) {
        BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", secu.name, secu.trdCode];
        
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://f10.chinabigdata.com/default.htm?c=%@&ql=1&istophide=1", [code lowercaseString]]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
    }
    return _webView;
}

@end
