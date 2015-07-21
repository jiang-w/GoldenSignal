//
//  NewsMainViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/2/25.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleTabViewController.h"
#import "NewsEventListViewController.h"

@interface NewsEventMainViewController : UIViewController<UIScrollViewDelegate, TitleTabViewDelegate, NewsEventListViewDelegate>
{
    TitleTabViewController *titleTabVC;
    UIScrollView *scrollView;
}

@end
