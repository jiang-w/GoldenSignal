//
//  NewsDetailViewController.m
//  CBNAPP
//
//  Created by Frank on 14-10-14.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "NewsEventDetailViewController.h"
#import "RegexKitLite.h"
#import "NewsDetailViewModel.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface NewsEventDetailViewController ()
{
    BDNews *_news;
    dispatch_queue_t loadDataQueue;
}
@end

@implementation NewsEventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    if (self.newsId) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"加载中...";
        loadDataQueue = dispatch_queue_create("loadData", nil);
        dispatch_async(loadDataQueue, ^{
            NewsDetailViewModel *model = [NewsDetailViewModel new];
            _news = [model getNewsById:self.newsId];
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
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${author}" withString:_news.author];
        // 新闻内容格式处理
        NSString *formatContent = [_news.content stringByReplacingOccurrencesOfRegex:@"\\s{2,}" withString:@"</p><p>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${content}" withString:formatContent];
    }
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:htmlText baseURL:baseURL];
}

@end
