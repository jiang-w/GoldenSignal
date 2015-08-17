//
//  ReportDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "ReportDetailViewController1.h"
#import "BDCoreService.h"
#import "RegexKitLite.h"
#import <MBProgressHUD.h>
#import <GRMustache.h>

@interface ReportDetailViewController1 ()

@end

@implementation ReportDetailViewController1
{
    BDReportDetail *_report;
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
            _report = [self getReportDetailById:self.contentId];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_report) {
                    [self loadNewsDetailPage];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
}

- (BDReportDetail *)getReportDetailById:(long)newsId {
    Stopwatch *watch = [Stopwatch startNew];
    BDReportDetail *report = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithLong:newsId] forKey:@"CONT_ID"];
    
    @try {
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1595 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            report = [[BDReportDetail alloc] init];
            report.innerId = newsId;
            report.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            report.date = [formatter dateFromString:item[@"PUB_DT"]];
            report.com = item[@"COM_NAME"];
            report.author = item[@"AUT"];
            report.content = item[@"CONT"];
            report.rating = item[@"RAT_ORIG_DESC"];
            report.rat_code =  (item[@"RAT_CODE"] == [NSNull null]) ? 0 : [item[@"RAT_CODE"] intValue];
            report.targ_prc = (item[@"TARG_PRC"] == [NSNull null]) ? 0 : [item[@"TARG_PRC"] floatValue];
            break;
        }
        
        [watch stop];
        NSLog(@"Success: 加载研报内容 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载研报内容 %@",exception.reason);
    }
    @finally {
        return report;
    }
}

- (void)loadNewsDetailPage {
    if (_report) {
        NSMutableDictionary *renderObject = [NSMutableDictionary dictionary];
        [renderObject setObject:_report.title forKey:@"title"];
        if (_report.date) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            [renderObject setObject:[dateFormatter stringFromDate:_report.date] forKey:@"date"];
        }
        else {
            [renderObject setObject:@"-" forKey:@"date"];
        }
        [renderObject setObject:_report.com forKey:@"com_name"];
        [renderObject setObject:_report.author forKey:@"author"];
        NSString *formatContent = [_report.content stringByReplacingOccurrencesOfRegex:@"\\s{2,}" withString:@"</p><p>"];
        [renderObject setObject:formatContent forKey:@"content"];
        [renderObject setObject:[NSString stringWithFormat:@"%@", _report.rating] forKey:@"rat_name"];
        [renderObject setObject:[NSString stringWithFormat:@"%d", _report.rat_code] forKey:@"rat_code"];
        if (_report.targ_prc != 0) {
            [renderObject setObject:[NSString stringWithFormat:@"%.2f", _report.targ_prc] forKey:@"prc"];
        }
        else {
            [renderObject setObject:@"--" forKey:@"prc"];
        }
        
        NSString *htmlText = [GRMustacheTemplate renderObject:renderObject fromResource:@"ReportDetail" bundle:nil error:NULL];
        [self.webView loadHTMLString:htmlText baseURL:nil];
    }
}

@end
