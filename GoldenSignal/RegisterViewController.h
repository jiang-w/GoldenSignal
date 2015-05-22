//
//  RegisterViewController.h
//  yicai_iso
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic, strong)IBOutlet UITextField *user;
@property(nonatomic, strong)IBOutlet UITextField *pwd;
@property(nonatomic, strong)IBOutlet UITextField *pwdAgain;
//@property(nonatomic, strong)IBOutlet UITextField *phone;
//@property(nonatomic, strong)IBOutlet UITextField *vCode;
//@property(nonatomic, strong)IBOutlet UITextField *eMail;

@property(nonatomic, strong)UIAlertView *alert;

@end
