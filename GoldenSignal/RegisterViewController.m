//
//  RegisterViewController.m
//  yicai_iso
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterViewModel.h"

@interface RegisterViewController ()
{
    RegisterViewModel *vm;
}
@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    vm = [[RegisterViewModel alloc] init];
    [self setupTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTextField
{
    _user.delegate = self;
    _pwd.delegate = self;
    _pwdAgain.delegate = self;
//    _phone.delegate = self;
//    _vCode.delegate = self;
//    _eMail.delegate = self;
    
    // 点击背景消失键盘
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    // 取消输入框第一响应
    [_user resignFirstResponder];
    [_pwd resignFirstResponder];
    [_pwdAgain resignFirstResponder];
//    [_phone resignFirstResponder];
//    [_vCode resignFirstResponder];
//    [_eMail resignFirstResponder];
}

- (IBAction)registerAccount:(id)sender
{
    if (![_pwd.text isEqual:_pwdAgain.text]) {
        self.alert.message = @"密码输入不一致";
        [self.alert show];
        return;
    }
    
    vm.loginName = _user.text;
    vm.pwd = _pwd.text;
    vm.pwdAgain = _pwdAgain.text;
    vm.phone = _user.text;
//    vm.vCode = _vCode.text;
    vm.eMail = _user.text;
    RegisterStatus status = [vm registerUser];
    if (status == success) {
        NSLog(@"注册用户成功");
    }
    else {
        self.alert.message = @"注册用户失败";
        [self.alert show];

    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}

@end
