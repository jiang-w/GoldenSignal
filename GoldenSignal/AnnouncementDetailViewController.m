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
#import <Masonry.h>
#import <GRMustache.h>

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.left.right.bottom.equalTo(self.view);
    }];
    
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
    if (_announcement) {
        NSMutableDictionary *renderObject = [NSMutableDictionary dictionary];
        [renderObject setObject:_announcement.title forKey:@"title"];
        if (_announcement.date) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [renderObject setObject:[dateFormatter stringFromDate:_announcement.date] forKey:@"date"];
        }
        else {
            [renderObject setObject:@"-" forKey:@"date"];
        }
        NSString *url = [NSString stringWithFormat:@"%@/%ld.%@", ATTACHMENT_SERVER_PATH, _announcement.ann_cont_id, _announcement.ann_fmt];
        [renderObject setObject:url forKey:@"url"];
        NSString *formatContent = [_announcement.content stringByReplacingOccurrencesOfRegex:@"\r\n" withString:@"<br />"];
        [renderObject setObject:formatContent forKey:@"content"];
        
        NSString *htmlText = [GRMustacheTemplate renderObject:renderObject fromResource:@"AnnouncementDetail" bundle:nil error:NULL];
        [self.webView loadHTMLString:htmlText baseURL:nil];
    }
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSURL *url = webView.request.URL;
    NSRange range = [url.relativePath rangeOfString:[NSString stringWithFormat:@"%ld.%@", _announcement.ann_cont_id, _announcement.ann_fmt]];
    if (range.length > 0) {
        self.webView.scalesPageToFit = YES;
    }
    else {
        self.webView.scalesPageToFit = NO;
    }
}

@end
