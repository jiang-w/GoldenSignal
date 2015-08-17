//
//  NewsEventDetailViewController.m
//  CBNAPP
//
//  Created by Frank on 14-10-14.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "NewsEventDetailViewController.h"
#import "BDNewsEventService.h"
#import "RegexKitLite.h"
#import <MBProgressHUD.h>
#import <GRMustache.h>

@interface NewsEventDetailViewController ()
{
    BDNewsEventDetail *_newsEvent;
    dispatch_queue_t loadDataQueue;
}
@end

@implementation NewsEventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    if (self.contentId) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"加载中...";
        loadDataQueue = dispatch_queue_create("loadData", nil);
        dispatch_async(loadDataQueue, ^{
            BDNewsEventService *service = [[BDNewsEventService alloc] init];
            _newsEvent = [service getNewsEventDetailById:self.contentId];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loadNewsEventDetailPage];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
}

- (void)loadNewsEventDetailPage {
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"NewsEventDetail" ofType:@"html"];
//    NSString* htmlTemplate = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    if (_newsEvent) {
        NSMutableDictionary *renderObject = [NSMutableDictionary dictionary];
        [renderObject setObject:_newsEvent.title forKey:@"title"];
        if (_newsEvent.date) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            [renderObject setObject:[dateFormatter stringFromDate:_newsEvent.date] forKey:@"date"];
        }
        else {
            [renderObject setObject:@"-" forKey:@"date"];
        }
        [renderObject setObject:_newsEvent.author forKey:@"author"];
        NSString *formatContent = [_newsEvent.content stringByReplacingOccurrencesOfRegex:@"\\s{2,}" withString:@"</p><p>"];
        [renderObject setObject:formatContent forKey:@"content"];
        
//        NSString* htmlText = [GRMustacheTemplate renderObject:renderObject fromString:htmlTemplate error:nil];
//        NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
        NSString *htmlText = [GRMustacheTemplate renderObject:renderObject fromResource:@"NewsEventDetail" bundle:nil error:NULL];
        [self.webView loadHTMLString:htmlText baseURL:nil];
    }
}

@end
