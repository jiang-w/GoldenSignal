//
//  AdViewController.m
//  CBNAPP
//
//  Created by Frank on 15/1/16.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "AdViewController.h"
#import "SideMenuViewController.h"

@interface AdViewController ()

@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(presentMainViewController:) userInfo:nil repeats:NO];
}

// 呈现首页
- (void)presentMainViewController:(NSTimer *)timer {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SideMenuViewController *sideMenu = [storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    UITabBarController *tabBar = [storyboard instantiateViewControllerWithIdentifier:@"RootTabBarController"];
    
    // 与GHRevealViewController进行绑定
    GHRevealViewController *revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
    revealController.view.backgroundColor = [UIColor whiteColor];
    revealController.contentViewController = tabBar;
    revealController.sidebarViewController = sideMenu;
    sideMenu.revealController = revealController;
    
    // 添加手势识别器，支持拖拽显示sideMenu
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:revealController action:@selector(dragContentView:)];
    panGesture.cancelsTouchesInView = YES;
    //[tabBar.view addGestureRecognizer:panGesture];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = revealController;
    //[self presentViewController:revealController animated:NO completion:nil];
}

@end
