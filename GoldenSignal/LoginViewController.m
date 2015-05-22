//
//  LoginViewController.m
//  yicai_iso
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "RegisterViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface LoginViewController ()
{
    LoginViewModel *vm;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    vm = [[LoginViewModel alloc] init];
    
    [_checkbox setImage:[UIImage imageNamed:@"checkbox_0"] forState:UIControlStateNormal];
    [_checkbox setImage:[UIImage imageNamed:@"checkbox_1"] forState:UIControlStateSelected];
    _checkbox.selected = vm.remember;
    if (vm.remember) {
        _user.text = vm.loginName;
        _pwd.text = vm.loginPwd;
    }
    
    // 点击背景消失键盘
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    _user.delegate = self;
    _pwd.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
}

- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    // 取消输入框第一响应
    [_user resignFirstResponder];
    [_pwd resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];   //点击Return后键盘消失
    return YES;
}

#pragma mark - Events

// 用户登录按钮事件
- (IBAction)login:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    vm.loginName = _user.text;
    vm.loginPwd = _pwd.text;
    LoginStatus status = [vm login];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (status == success) {
        NSLog(@"登录成功！");
    }
    else {
        NSLog(@"登录失败！");
    }
}

// 用户注册按钮事件
- (IBAction)registerAccount:(id)sender
{
    RegisterViewController *registerVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [[self navigationController] pushViewController:registerVC animated:YES];
}

// 记住密码按钮事件
- (IBAction)checkboxClick:(id)sender
{
    UIButton *checkbox = (UIButton *)sender;
    checkbox.selected = !checkbox.selected;
    vm.remember = checkbox.selected;
}

@end
