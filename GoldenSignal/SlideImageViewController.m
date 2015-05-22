//
//  SlideImageViewController.m
//  CBNAPP
//
//  Created by Frank on 15/1/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SlideImageViewController.h"

@interface SlideImageViewController ()
{
    NSMutableArray *_slideImages;
}

@end

@implementation SlideImageViewController

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self.view setFrame:frame];
        // 初始化图片
        _slideImages = [[NSMutableArray alloc] init];
        [_slideImages addObject:@"http://www.chinabigdata.com/images/Banner1.jpg"];
        [_slideImages addObject:@"http://www.chinabigdata.com/images/Banner2.jpg"];
        [_slideImages addObject:@"http://www.chinabigdata.com/images/Banner3.jpg"];
        // 初始化 scrollView
        [self initScrollView];
        // 初始化 pageControl
        [self initPageControl];
        // 定时器循环
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(revolvingPage) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initScrollView {
    imageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    imageScrollView.delegate = self;
    imageScrollView.pagingEnabled = YES;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:imageScrollView];
    
    NSInteger imageCount = _slideImages.count;
    if (imageCount > 0) {
        CGFloat pageWidth = CGRectGetWidth(imageScrollView.frame);
        CGFloat pageHeight = CGRectGetHeight(imageScrollView.frame);
        // 设置 contentSize
        [imageScrollView setContentSize:CGSizeMake(pageWidth * (imageCount + 2), pageHeight)];
        [imageScrollView setContentOffset:CGPointMake(0, 0)];
        // 添加图片
        for (int i = 0; i < _slideImages.count; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pageWidth * (i + 1), 0, pageWidth, pageHeight)];
            [imageView setImageWithUrl:[NSURL URLWithString:[_slideImages objectAtIndex:i]]];
            [imageScrollView addSubview:imageView];
        }
        // 取数组最后一张图片 放在第一页
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, pageHeight)];
        [imageView setImageWithUrl:[NSURL URLWithString:[_slideImages lastObject]]];
        [imageScrollView addSubview:imageView];
        // 取数组第一张图片 放在最后一页
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pageWidth * (_slideImages.count + 1), 0, pageWidth, pageHeight)];
        [imageView setImageWithUrl:[NSURL URLWithString:[_slideImages firstObject]]];
        [imageScrollView addSubview:imageView];
        // 从第二张图片开始显示
        [imageScrollView scrollRectToVisible:CGRectMake(pageWidth, 0, pageWidth, pageHeight) animated:NO];
    }
}

- (void)initPageControl {
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageScrollView.frame)-37, CGRectGetWidth(imageScrollView.frame), 37)];
    pageControl.numberOfPages = _slideImages.count;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
}

// 定时器绑定的方法
- (void)revolvingPage {
    CGFloat pageWidth = CGRectGetWidth(imageScrollView.frame);
    CGFloat pageHeight = CGRectGetHeight(imageScrollView.frame);
    NSInteger page = pageControl.currentPage; // 获取当前的page
    page++;
    page = page >= pageControl.numberOfPages  ? 0 : page ;
    pageControl.currentPage = page;
    [imageScrollView scrollRectToVisible:CGRectMake(pageWidth * (page + 1), 0, pageWidth, pageHeight) animated:NO];
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    CGFloat pageHeight = CGRectGetHeight(scrollView.frame);
    NSInteger index = scrollView.contentOffset.x / pageWidth;
    if (index == 0) {
        pageControl.currentPage =  _slideImages.count - 1;
        [scrollView scrollRectToVisible:CGRectMake(pageWidth * _slideImages.count, 0, pageWidth, pageHeight) animated:NO];
    }
    else if (index == _slideImages.count + 1) {
        pageControl.currentPage =  0;
        [scrollView scrollRectToVisible:CGRectMake(pageWidth, 0, pageWidth, pageHeight) animated:NO];
    }
    else {
        pageControl.currentPage =  index - 1;
    }
}

@end
