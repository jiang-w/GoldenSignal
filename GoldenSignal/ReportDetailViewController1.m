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
        loadDataQueue = dispatch_queue_create("loadData", nil);
        dispatch_async(loadDataQueue, ^{
            _report = [self getReportDetailById:self.contentId];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loadNewsDetailPage];
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
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ReportDetail" ofType:@"html"];
    NSString* htmlText = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    if (_report) {
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${title}" withString:_report.title];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        if (_report.date) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${date}" withString:[dateFormatter stringFromDate:_report.date]];
        }
        else {
            htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${date}" withString:@"-"];
        }
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${com_name}" withString:[NSString stringWithFormat:@"%@", _report.com]];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${author}" withString:[NSString stringWithFormat:@"%@", _report.author]];
        // 新闻内容格式处理
        NSString *formatContent = [_report.content stringByReplacingOccurrencesOfRegex:@"\\s{2,}" withString:@"</p><p>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${content}" withString:formatContent];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${rat_name}" withString:[NSString stringWithFormat:@"%@", _report.rating]];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${rat_code}" withString:[NSString stringWithFormat:@"%d", _report.rat_code]];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"${prc}" withString:[NSString stringWithFormat:@"%.2f", _report.targ_prc]];
    }
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:htmlText baseURL:baseURL];
}

@end
