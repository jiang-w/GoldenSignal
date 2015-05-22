//
//  NewsMainViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleTabViewController.h"
#import "NewsListViewController.h"

@interface NewsMainViewController : UIViewController<UIScrollViewDelegate, TitleTabViewDelegate, NewsListViewDelegate>
{
    TitleTabViewController *titleTabVC;
    UIScrollView *scrollView;
}

@end
