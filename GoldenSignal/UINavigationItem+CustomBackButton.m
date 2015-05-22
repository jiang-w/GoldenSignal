//
//  UINavigationItem+CustomBackButton.m
//  CBNAPP
//
//  Created by Frank on 14-10-13.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "UINavigationItem+CustomBackButton.h"
#import <objc/runtime.h>

@implementation UINavigationItem (CustomBackButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换一下两个方法的实现
        Method originalMethodImp = class_getInstanceMethod(self, @selector(backBarButtonItem));
        Method destMethodImp = class_getInstanceMethod(self, @selector(myCustomBackButton_backBarbuttonItem));
        method_exchangeImplementations(originalMethodImp, destMethodImp);
    });
}

static char kCustomBackButtonKey;
- (UIBarButtonItem *)myCustomBackButton_backBarbuttonItem {
    UIBarButtonItem *item = [self myCustomBackButton_backBarbuttonItem];
    if (item) {
        // backBarButtonItem不为空，直接返回
        return item;
    }
    item = objc_getAssociatedObject(self, &kCustomBackButtonKey);
    if (!item) {
        // 默认情况下，让后退按钮只显示箭头而不带文字
        item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        objc_setAssociatedObject(self, &kCustomBackButtonKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return item;
}

// 全局修改导航栏标题
-(NSString *)title {
    return @"第一财经・金信号";
}

- (void)dealloc {
    objc_removeAssociatedObjects(self);
}

@end
