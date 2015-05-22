//
//  CustomTagViewController.h
//  CBNAPP
//
//  Created by Frank on 14-10-15.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTagViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain) IBOutlet UITableView *topTagsTableView;

@property(nonatomic, retain) IBOutlet UITableView *subTagsTableView;

@end


/**
 *  二级标签单元格
 */
@interface SubTagTableViewCell : UITableViewCell

@property(nonatomic, retain) BDNewsTag *tag;

@property(nonatomic, retain) IBOutlet UIButton *checkMarkBtn;

@property(nonatomic, assign, setter=setIsCustom:, getter=getIsCustom) BOOL isCustom;

@end