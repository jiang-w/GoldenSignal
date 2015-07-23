//
//  NewsDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "BDStockNewsService.h"
#import "RegexKitLite.h"
#import <MBProgressHUD.h>

@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController
{
    BDNews *_news;
    dispatch_queue_t loadDataQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    if (self.contentId > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"加载中...";
        loadDataQueue = dispatch_queue_create("loadData", nil);
        dispatch_async(loadDataQueue, ^{
            BDStockNewsService *service = [[BDStockNewsService alloc] init];
            _news = [service getNewsDetailById:self.contentId];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loadNewsDetailPage];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }

}

- (void)loadNewsDetailPage {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"NewsDetail" ofType:@"html"];
    NSString* htmlText = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    if (_news) {
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${title}" withString:_news.title];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        if (_news.date) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${date}" withString:[dateFormatter stringFromDate:_news.date]];
        }
        else {
            htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${date}" withString:@"-"];
        }
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${media}" withString:[NSString stringWithFormat:@"%@", _news.media]];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${author}" withString:[NSString stringWithFormat:@"%@", _news.author]];
        // 新闻内容格式处理
        NSString *formatContent = [_news.content stringByReplacingOccurrencesOfRegex:@"\\s{2,}" withString:@"</p><p>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${content}" withString:formatContent];
    }
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:htmlText baseURL:baseURL];
}

@end
