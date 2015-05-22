//
//  F10ViewController.m
//  CBNAPP
//
//  Created by Frank on 15/1/12.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "F10ViewController.h"

@interface F10ViewController ()

@end

@implementation F10ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    if (![self.code isNullOrEmpty]) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://f10.chinabigdata.com/default.htm?c=%@&ql=1"
                                                    , [self.code lowercaseString]]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
