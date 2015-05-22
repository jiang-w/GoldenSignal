//
//  SlideImageViewController.h
//  CBNAPP
//
//  Created by Frank on 15/1/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideImageViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *imageScrollView;
    UIPageControl *pageControl;
}

- (id)initWithFrame:(CGRect)frame;

@end
