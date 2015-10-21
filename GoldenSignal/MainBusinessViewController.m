//
//  MainBusinessViewController.m
//  GoldenSignal
//
//  Created by CBD on 15/8/12.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "MainBusinessViewController.h"//主营
#import "BDDiagnoseContentService.h"
#import "PieChartView.h"
#import <Masonry.h>

#define whiteDarkColor [[UIColor whiteColor]colorWithAlphaComponent:0.8]
@interface MainBusinessViewController ()
{
    NSMutableArray *_dataArray;
    NSMutableArray *_dataArray2;
    BDDiagnoseContentService *_diagnoseService;
    CGFloat _desLblHeight;
}
@end

@implementation MainBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(22, 25, 30);
    self.baseView = [[UIView alloc]init];
//    self.baseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    [self getData];
//    [self unscrambleView];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.baseView);
    }];
    
}

- (void)getData{
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray2 = [[NSMutableArray alloc]init];
    _diagnoseService = [[BDDiagnoseContentService alloc]init];
    
    _dataArray = [_diagnoseService getDiagnoseEachPageWithPageId:1600 andBD_CODE:self.BD_CODE];
    _dataArray2 = [_diagnoseService getDiagnoseEachPageWithPageId:1601 andBD_CODE:self.BD_CODE];
    
//    _dataArray = nil;
    if (_dataArray == nil || _dataArray.count == 0) {
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.view.frame.size.height - 449 +100);
        }];
        self.view.backgroundColor = RGB(22, 25, 30);
        [self noDataView];
        return;
    }
    
    [self creatPieView];
}

- (void)creatPieView{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
//    titleLabel.backgroundColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:13];
    titleLabel.textColor = whiteDarkColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"主营业务构成";
    [self.baseView addSubview:titleLabel];
    
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 200, 20)];
    dateLabel.font = [UIFont systemFontOfSize:13];
    dateLabel.text = [NSString stringWithFormat:@" 截止日期：%@",[(BDDiagnoseModel *)_dataArray[0] END_DT]];
    dateLabel.textColor = whiteDarkColor;
    [self.baseView addSubview:dateLabel];
    
    
    NSMutableArray *valueArray = [[NSMutableArray alloc]init];
    for (BDDiagnoseModel *dModel in _dataArray) {
        [valueArray addObject:dModel.OPER_INC];
    }
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithObjects:
                                  [UIColor greenColor],
                                  RGB(60, 110, 190),
                                  RGB(60, 170, 255),
                                  RGB(240, 160, 90),
                                  RGB(130, 130, 130),
                                  RGB(230, 90, 130),
                                  RGB(225, 210, 80),
                                  [UIColor blueColor],
                                  [UIColor redColor],
                                  [UIColor purpleColor],
                                  nil];
    // 必须先创建一个相同大小的container view，再将PieChartView add上去
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake((320 - 130) / 2, 60, 130, 130)];
    PieChartView* pieView = [[PieChartView alloc] initWithFrame:CGRectMake(0, 0, 130, 130)];
    //    pieView.userInteractionEnabled = NO;
    [self.baseView addSubview:containerView];
    [containerView addSubview:pieView];
    
    pieView.mValueArray = [NSMutableArray arrayWithArray:valueArray];
    pieView.mColorArray = [NSMutableArray arrayWithArray:colorArray];
    
    UIView *sayView = [[UIView alloc]init];
    //    sayView.backgroundColor = [UIColor cyanColor];
    [self.baseView addSubview:sayView];
    [sayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view).offset(0);
        
        if (_dataArray.count==1 || _dataArray.count==2) {
            make.height.mas_equalTo(15);
        }
        else if (_dataArray.count==3 || _dataArray.count==4) {
            make.height.mas_equalTo(35);
        }
        else if (_dataArray.count==5 || _dataArray.count==6) {
            make.height.mas_equalTo(55);
        }
        else if (_dataArray.count==7 || _dataArray.count==8) {
            make.height.mas_equalTo(75);
        }
        else if (_dataArray.count==9 || _dataArray.count==10){
            make.height.mas_equalTo(95);
        }
        else {
            make.height.mas_equalTo( 0);
        }
    }];
    
    for (int i=1; i<=_dataArray.count; i++) {
        int row = ceil(i/2.0);
        int col = i % 2 == 0 ? 2 : i%2;
        DEBUGLog(@">>%d,%d",row,col);
        
        //!颜色块
        UILabel *stateLabel = [[UILabel alloc]init];
        stateLabel.frame = CGRectMake(20+150*(col-1), 0+20*(row-1), 20, 15);
        //stateLabel.backgroundColor = [UIColor yellowColor];
        stateLabel.backgroundColor = colorArray[i-1];
        [sayView addSubview:stateLabel];
        
        //!说明标示
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.frame = CGRectMake(45+150*(col-1), 0+20*(row-1), 120, 15);
//        titleLabel.backgroundColor = [UIColor purpleColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = whiteDarkColor;
        [sayView addSubview:titleLabel];
        titleLabel.text = [(BDDiagnoseModel *)_dataArray[i-1] BIZ_NAME_NORM];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        DEBUGLog(@">>%@",titleLabel.text);
    }
    
    //}
    //
    //_content	__NSCFString *	@"公司2015-06-30财报显示：\r业务收入91.03%来自于钢铁业，贡献收入2094008.31万元，毛利率6.05%，同比增长-16.03%；业务收入8.97%来自于其他业务，贡献收入206383.99万元，毛利率0.45%。\r毛利率最高的是钢铁业，达到6.05%，贡献收入2094008.31万元。"	0x00007fc091de7280
    ////解读view
    //- (void)unscrambleView{
    UILabel *unscrambleLabel = [[UILabel alloc]init];
    //unscrambleLabel.backgroundColor = [UIColor yellowColor];
    unscrambleLabel.numberOfLines = 0;
    unscrambleLabel.font = [UIFont systemFontOfSize:13];
    unscrambleLabel.textColor = whiteDarkColor;
    unscrambleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSString *DECStr = nil;
    if (_dataArray2.count != 0 ) {
        DECStr = [(BDDiagnoseModel *)_dataArray2[0] DEC];
    } else {
        DECStr = @"暂无相关描述信息";
    }
    
    DECStr = [DECStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    DECStr = [DECStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    unscrambleLabel.text = DECStr;
    DEBUGLog(@"DEC>>%@",unscrambleLabel.text);
    
    //_desLblHeight = [self calcHightWithString:unscrambleLabel];没用上
    [self.baseView addSubview:unscrambleLabel];
    
    [unscrambleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sayView.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(unscrambleLabel.mas_bottom).offset(10);
    }];
}

//计算文本label的高度
- (CGFloat)calcHightWithString:(UILabel *)label{
    return  [label.text boundingRectWithSize:CGSizeMake(label.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.height;
}



- (void)noDataView{
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, 30, self.view.frame.size.width, 25);
    //    label.backgroundColor = [UIColor cyanColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"暂时没有数据";
    label.textColor = whiteDarkColor;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
