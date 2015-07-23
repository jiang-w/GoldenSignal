//
//  PerformanceTableViewCell.h
//  
//
//  Created by CBD on 7/22/15.
//
//

#import <UIKit/UIKit.h>

@interface PerformanceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *title1;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;




- (void)showGongGaoCellAndModel:(NSObject *)model;
- (void)showYeJiCellAndModel:(NSObject *)model;

//赋值 and 自动换行,计算出cell的高度
-(void)setContentLabels:(UILabel *)label andText:(NSString *)text;


@end
