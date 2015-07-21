//
//  OptionalGSViewController.h
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/12/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionalGSDelegate <NSObject>

- (void)didSelectRowNews:(BDNews *)news;

@end

@interface OptionalGSViewController : UITableViewController


@property (nonatomic,strong) id <OptionalGSDelegate> delegate;


- (id)initWithOpGoldSignId:(long)OpGoldSignId;

@property (nonatomic, assign) int pageNum;

@end
