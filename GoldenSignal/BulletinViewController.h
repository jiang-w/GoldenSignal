//
//  BulletinViewController.h
//  GoldenSignal
//
//  Created by CBD on 7/2/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDBulletin.h"

@interface BulletinViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *baseView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *secView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *pdfButton;

@property (weak, nonatomic) IBOutlet UILabel *readLabel;


@property (weak, nonatomic) IBOutlet UIWebView *webView;



//公告id    / 序号 sn
- (id)initWithModel:(NSObject *)model andId:(long)innerId;



@end
