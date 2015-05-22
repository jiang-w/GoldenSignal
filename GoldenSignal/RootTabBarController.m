//
//  RootTabBarController.m
//  CBNAPP
//
//  Created by Frank on 14-10-9.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "RootTabBarController.h"

@interface RootTabBarController ()

- (void)loadCustomTabBarView;

@end

@implementation RootTabBarController
{
    NSMutableArray *_customTabButtons;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCustomTabBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCustomTabBarView {
    _customTabButtons = [NSMutableArray arrayWithCapacity:4];
    UIView *customTabBarView = [[UIView alloc] init];
    customTabBarView.frame = CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    
    NSArray *imgs = @[@"金信号_0",@"行情_0",@"自选股_0",@"设置_0"];
    NSArray *selImgs = @[@"金信号_1",@"行情_1",@"自选股_1",@"设置_1"];
    CGFloat imgWidth = self.view.frame.size.width / imgs.count;
    CGFloat imgHeight = customTabBarView.frame.size.height;
    
    for (int i = 0; i < imgs.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0 + imgWidth * i, 0, imgWidth, imgHeight)];
        [btn setBackgroundImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:selImgs[i]] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventTouchUpInside];
        [_customTabButtons addObject:btn];
        [customTabBarView addSubview:btn];
    }
    
    if (_customTabButtons.count > 0) {
        ((UIButton *)_customTabButtons[0]).selected = YES;
    }
    [self.tabBar addSubview:customTabBarView];
}

- (void)changeViewController:(id)sender {
    for (int i = 0; i < _customTabButtons.count; i++) {
        UIButton *btn = (UIButton *)_customTabButtons[i];
        if (btn != sender) {
            btn.selected = NO;
        }
        else {
            btn.selected = YES;
            self.selectedIndex = i;
        }
    }
}

@end
