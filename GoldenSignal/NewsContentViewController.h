//
//  NewsContentViewController.h
//  GoldenSignal
//
//  Created by CBD on 7/3/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDNews.h"

@interface NewsContentViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;//详细内容描述




/***
 *  @param model     传的model
 *  @param connectId 链接cell与详细页的id
 *  @param pageId    页面Id
 *
 *  @return 
 */
- (instancetype)initWithModel:(NSObject *)model andId:(long)connectId andPageId:(int)pageId;







@end
