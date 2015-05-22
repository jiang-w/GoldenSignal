//
//  KeyboardWizardViewController.h
//  CBNAPP
//
//  Created by Frank on 14/11/18.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardWizardViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *searchResults;
}

@property(nonatomic, strong) IBOutlet UISearchBar *secuSearchBar;

@end
