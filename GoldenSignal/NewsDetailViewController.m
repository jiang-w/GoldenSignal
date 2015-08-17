//
//  NewsDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/23.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "BDCoreService.h"
#import "RegexKitLite.h"
#import <MBProgressHUD.h>
#import <GRMustache.h>

@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController
{
    BDNewsDetail *_news;
    dispatch_queue_t loadDataQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    if (self.contentId > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"加载中...";
        hud.opacity = 0;
        hud.activityIndicatorColor = [UIColor blackColor];
        loadDataQueue = dispatch_queue_create("loadData", nil);
        dispatch_async(loadDataQueue, ^{
            _news = [self getNewsDetailById:self.contentId];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loadNewsDetailPage];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
}

- (BDNewsDetail *)getNewsDetailById:(long)newsId {
    Stopwatch *watch = [Stopwatch startNew];
    BDNewsDetail *news = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithLong:newsId] forKey:@"CONT_ID"];
    
    @try {
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1588 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            news = [[BDNewsDetail alloc] init];
            news.innerId = newsId;
            news.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            news.date = [formatter dateFromString:item[@"PUB_DT"]];
            news.media = item[@"MED_NAME"];
            news.author = item[@"AUT"];
            news.content = item[@"CONT"];
            break;
        }
        
        [watch stop];
        NSLog(@"Success: 加载新闻内容 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载新闻内容 %@",exception.reason);
    }
    @finally {
        return news;
    }
}

- (void)loadNewsDetailPage {
    if (_news) {
        NSMutableDictionary *renderObject = [NSMutableDictionary dictionary];
        [renderObject setObject:_news.title forKey:@"title"];
        if (_news.date) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            [renderObject setObject:[dateFormatter stringFromDate:_news.date] forKey:@"date"];
        }
        else {
            [renderObject setObject:@"-" forKey:@"date"];
        }
        [renderObject setObject:_news.media forKey:@"media"];
        [renderObject setObject:_news.author forKey:@"author"];
        NSString *formatContent = [_news.content stringByReplacingOccurrencesOfRegex:@"\\s{2,}" withString:@"</p><p>"];
        [renderObject setObject:formatContent forKey:@"content"];

        NSString *htmlText = [GRMustacheTemplate renderObject:renderObject fromResource:@"NewsDetail" bundle:nil error:NULL];
        [self.webView loadHTMLString:htmlText baseURL:nil];
    }
}

@end
