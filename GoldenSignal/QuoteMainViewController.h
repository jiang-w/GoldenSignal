//
//  QuoteMainViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectQuoteViewController.h"
#import "SectCollectionViewController.h"
#import "TitleTabViewController.h"

@interface QuoteMainViewController : UIViewController<UIScrollViewDelegate, SectQuoteViewDelegate, TitleTabViewDelegate, SectCollectionViewDelegate>
{
    UIScrollView *scrollView;
    TitleTabViewController *titleTabVC;
}

@end
