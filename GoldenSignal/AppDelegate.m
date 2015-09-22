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
#import "StkDetailViewController.h"
#import "IdxDetailViewController.h"
#import "BDStockPoolInfoService.h"
#import "BDNetworkService.h"

#import <MBProgressHUD.h>
#import <ReactiveCocoa.h>

@implementation AppDelegate
{
    NSTimer *checkTimer;
}

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
    
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkConnected) userInfo:nil repeats:YES];
    
    [self observeNetworkStatus];
    [self infomations];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [checkTimer setFireDate:[NSDate distantFuture]];
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
    [checkTimer setFireDate:[NSDate date]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 收到键盘精灵通知后，触发
- (void)pushStockViewController:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:dic[@"BD_CODE"]];
    GHRevealViewController *root = (GHRevealViewController *)self.window.rootViewController;
    UITabBarController *tab = (UITabBarController *)root.contentViewController;
    UINavigationController *navigation = (UINavigationController *)tab.viewControllers[tab.selectedIndex];
    UIViewController *top = [navigation.viewControllers lastObject];
    
    if ([top isKindOfClass:[IdxDetailViewController class]] || [top isKindOfClass:[StkDetailViewController class]]) {
        [navigation popViewControllerAnimated:NO];
    }
    switch (secu.typ) {
        case idx: {
            IdxDetailViewController *idxVC = [[IdxDetailViewController alloc] initWithIdxCode:secu.bdCode];
            [navigation pushViewController:idxVC animated:YES];
//            NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)idxVc));
        }
            break;
        case stock: {
            StkDetailViewController *stkVC = [[StkDetailViewController alloc] initWithSecuCode:secu.bdCode];
            [navigation pushViewController:stkVC animated:YES];
        }
        default:
            break;
    }
    [navigation setNavigationBarHidden:NO animated:NO];
}

- (NSNumber *)createUserIdentity {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMddHHmmss"];
    NSString *valueString = [NSString stringWithFormat:@"5%@%d%d", [dateFormatter stringFromDate:[NSDate date]], arc4random() % 10, arc4random() % 10];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *identity = [numberFormatter numberFromString:valueString];
    return identity;
}

// 定时检测与行情服务器的连接状态，断开后尝试重连
- (void)checkConnected {
    BDQuotationService *service = [BDQuotationService sharedInstance];
    if (!service.isConnected) {
        [service connect];
    }
}

- (void)infomations{
    NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString] ;
    DEBUGLog(@"手机序列号: %@",identifierNumber);
    //手机别名： 用户定义的名称
    
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    DEBUGLog(@"手机别名: %@", userPhoneName);
    //设备名称
    
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    DEBUGLog(@"设备名称: %@",deviceName );
    //手机系统版本
    
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    DEBUGLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    
    NSString* phoneModel = [[UIDevice currentDevice] model];
    DEBUGLog(@"手机型号: %@",phoneModel );
    
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    DEBUGLog(@"国际化区域名称: %@",localPhoneModel );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    DEBUGLog(@"当前应用名称：%@",appCurName);
    
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    DEBUGLog(@"当前应用软件版本:%@",appCurVersion);
    
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    DEBUGLog(@"当前应用版本号码：%@",appCurVersionNum);
}

- (void)observeNetworkStatus {
    BDNetworkService *network = [BDNetworkService sharedInstance];
    @weakify(self);
    [RACObserve(network, networkStatus) subscribeNext:^(id x) {
        @strongify(self);
        NetworkStatus status = [x intValue];
        if (status == NotReachable) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"连接失败，请检查网络设置";
            hud.labelFont = [UIFont systemFontOfSize:11];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:self.window animated:YES];
            });
        }
    }];
}

@end
