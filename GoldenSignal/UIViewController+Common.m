//
//  UIViewController+Common.m
//  GoldenSignal
//
//  Created by Frank on 15/7/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "UIViewController+Common.h"

@implementation UIViewController (Common)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIResponder *object = self;
    while (object) {
        if (![object isKindOfClass:[UIViewController class]]) {
            object = [object nextResponder];
        }
        else if ([object isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)object;
            [nav pushViewController:viewController animated:animated];
            break;
        }
        else {
            UIViewController *controller = (UIViewController *)object;
            UINavigationController *nav = controller.navigationController;
            if (nav) {
                [nav pushViewController:viewController animated:animated];
                break;
            }
            else {
                object = [object nextResponder];
            }
        }
    }
}

@end
