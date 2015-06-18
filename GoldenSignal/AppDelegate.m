//
//  AppDelegate.m
//  CBNAPP
//
//  Created by Frank on 14-8-12.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "AppDelegate.h"
#import "BDQuotationService.h"
#import "SideMenuViewController.h"
#import "AdViewController.h"
#import "StockViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        NSLog(@"是第一次启动");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSNumber *userIdentity = [self createUserIdentity];
        [[NSUserDefaults standardUserDefaults] setValue:userIdentity forKey:@"userIdentity"];
    }
    
    dispatch_queue_t queue = dispatch_queue_create("initApplicationData", nil);
    dispatch_async(queue, ^{
        // 更新键盘精灵数据
        [[BDKeyboardWizard sharedInstance] update];
    });
    
    // 获取Storyboard中的视图控制器
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AdViewController *adVC = [storyboard instantiateViewControllerWithIdentifier:@"AdViewController"];
    self.window.rootViewController = adVC;  //加载海报视图
    // 接收键盘精灵通知
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(pushStockViewController:) name:KEYBOARD_WIZARD_NOTIFICATION object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 中断与行情服务器的连接
    BDQuotationService *service = [BDQuotationService sharedInstance];
    [service disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 与行情服务器建立连接
    BDQuotationService *service = [BDQuotationService sharedInstance];
    [service connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 收到键盘精灵通知后，触发
- (void)pushStockViewController:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *bdCode = dic[@"BD_CODE"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StockViewController *stockVC = [storyboard instantiateViewControllerWithIdentifier:@"StockViewController"];
    stockVC.defaultCode = bdCode;
    GHRevealViewController *root = (GHRevealViewController *)self.window.rootViewController;
    UITabBarController *tab = (UITabBarController *)root.contentViewController;
    UINavigationController *navigation = (UINavigationController *)tab.viewControllers[tab.selectedIndex];
    UIViewController *top = [navigation.viewControllers lastObject];
    if (![top isKindOfClass:[StockViewController class]]) {
        [navigation pushViewController:stockVC animated:YES];
    }
}

- (NSNumber *)createUserIdentity {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMddHHmmss"];
    NSString *valueString = [NSString stringWithFormat:@"5%@%d%d", [dateFormatter stringFromDate:[NSDate date]], arc4random() % 10, arc4random() % 10];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *identity = [numberFormatter numberFromString:valueString];
    return identity;
}

@end
