//
//  NewsDetailViewController.h
//  CBNAPP
//
//  Created by Frank on 14-10-14.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDNews.h"

@interface NewsEventDetailViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic, strong) IBOutlet UIWebView *webView;

@property(nonatomic, assign)long newsId;

@end
