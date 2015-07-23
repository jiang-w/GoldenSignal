//
//  InfomationsTableViewCell.h
//  GoldenSignal
//
//  Created by CBD on 6/19/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDPrompt.h"

@interface InfomationsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *title1;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic,assign) CGFloat titleLabelHeight;


- (void)showTiShiCellAndModel:(NSObject *)model;

@end
