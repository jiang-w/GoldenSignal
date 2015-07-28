//
//  AnnouncementDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/28.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "AnnouncementDetailViewController.h"
#import "BDCoreService.h"
#import "RegexKitLite.h"
#import <MBProgressHUD.h>

@interface AnnouncementDetailViewController ()

@end

@implementation AnnouncementDetailViewController
{
    BDAnnouncementDetail *_announcement;
    dispatch_queue_t loadDataQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
//    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    if (self.contentId > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"加载中...";
        hud.opacity = 0;
        hud.activityIndicatorColor = [UIColor blackColor];
        loadDataQueue = dispatch_queue_create("loadData", nil);
        dispatch_async(loadDataQueue, ^{
            _announcement = [self getAnnouncementDetailById:self.contentId];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loadNewsDetailPage];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }

}

- (BDAnnouncementDetail *)getAnnouncementDetailById:(long)newsId {
    Stopwatch *watch = [Stopwatch startNew];
    BDAnnouncementDetail *announcement = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithLong:newsId] forKey:@"ID"];
    
    @try {
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1589 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            announcement = [[BDAnnouncementDetail alloc] init];
            announcement.innerId = newsId;
            announcement.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            announcement.date = [formatter dateFromString:item[@"PUB_DT"]];
            announcement.content = (item[@"CONT"] == [NSNull null]) ? @"" : item[@"CONT"];
            announcement.ann_fmt = item[@"ANN_FMT"];
            announcement.ann_cont_id = (item[@"ANN_CONT_ID"] == [NSNull null]) ? 0 : [item[@"ANN_CONT_ID"] longValue];
            break;
        }
        
        [watch stop];
        NSLog(@"Success: 加载公告内容 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载公告内容 %@",exception.reason);
    }
    @finally {
        return announcement;
    }
}

- (void)loadNewsDetailPage {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"AnnouncementDetail" ofType:@"html"];
    NSString* htmlText = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    if (_announcement) {
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${title}" withString:_announcement.title];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        if (_announcement.date) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${date}" withString:[dateFormatter stringFromDate:_announcement.date]];
        }
        else {
            htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${date}" withString:@"-"];
        }
        // 新闻内容格式处理
        NSString *formatContent = [_announcement.content stringByReplacingOccurrencesOfRegex:@"\r\n" withString:@"<br />"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${content}" withString:formatContent];
        NSString *url = [NSString stringWithFormat:@"%@/%ld.%@", ATTACHMENT_SERVER_PATH, _announcement.ann_cont_id, _announcement.ann_fmt];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${url}" withString:url];
    }
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:htmlText baseURL:baseURL];
}

@end
