//
//  QuoteMainViewController.h
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectQuoteViewController.h"
#import "IndexQuoteViewController.h"
#import "SectCollectionViewController.h"
#import "TitleTabViewController.h"

@interface QuoteMainViewController : UIViewController<UIScrollViewDelegate, SectQuoteViewDelegate, IndexQuoteViewDelegate, TitleTabViewDelegate, SectCollectionViewDelegate>
{
    UIScrollView *scrollView;
    TitleTabViewController *titleTabVC;
}

@end
