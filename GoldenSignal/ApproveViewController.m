//
//  ApproveViewController.m
//  GoldenSignal
//
//  Created by CBD on 15/8/13.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "ApproveViewController.h"//认同
#import "BDDiagnoseContentService.h"
#import <Masonry.h>
#import "SCChart.h"


@interface ApproveViewController ()<SCChartDataSource>
{
    NSMutableArray *_dataArray;
    NSMutableArray *_dataArray2;
    BDDiagnoseContentService *_diagnoseService;
    CGFloat _desLblHeight;
    
    NSInteger *_path;
    SCChart *_chartView;
    NSMutableArray *_ratAry;
}
@end

@implementation ApproveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseView = [[UIView alloc]init];
//    self.baseView.frame = self.view.frame;
    [self.view addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    
    [self getData];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.baseView);
    }];

}

- (void)getData{
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray2 = [[NSMutableArray alloc]init];
    _diagnoseService = [[BDDiagnoseContentService alloc]init];
    
    _dataArray = [_diagnoseService getDiagnoseEachPageWithPageId:1602 andBD_CODE:self.BD_CODE];
    _dataArray2 = [_diagnoseService getDiagnoseEachPageWithPageId:1603 andBD_CODE:self.BD_CODE];
    
//    _dataArray = nil;
    if (_dataArray == nil || _dataArray.count == 0) {
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.view.frame.size.height - 449 +100);
        }];
        self.view.backgroundColor = [UIColor whiteColor];
        [self noDataView];
        return;
    }
    
    [self shuju];
    [self graphView];
    [self explainGraph];
    [self unscrambleView];
}


- (void)explainGraph{
    NSArray *titleArray = @[@"买入",@"增持",@"中性",@"减持",@"卖出"];
    for (int i = 1; i<= 5; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame =  CGRectMake(i*50-17, 215, 13, 13);
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rat0%d.png",i]];
        [self.baseView addSubview:imageView];
        
        UILabel *titleLable = [[UILabel alloc]init];
        titleLable.frame = CGRectMake(i*50, 215, 30, 13);
        titleLable.font = [UIFont systemFontOfSize:13];
        titleLable.text = titleArray[i-1];
        [self.baseView addSubview:titleLable];
    }
}

//解读view
- (void)unscrambleView{
    
    CGRect frame = CGRectMake(10, 240, self.view.frame.size.width-20, 16);
    UILabel *unscrambleLabel = [[UILabel alloc]initWithFrame:frame];
//    unscrambleLabel.backgroundColor = [UIColor yellowColor];
    unscrambleLabel.numberOfLines = 0;
    unscrambleLabel.font = [UIFont systemFontOfSize:13];
    unscrambleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    for (BDDiagnoseModel * dModel in _dataArray2) {
        NSString *DECStr = dModel.DES;
        DECStr = [DECStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        DECStr = [DECStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        unscrambleLabel.text = DECStr;
    }
    _desLblHeight = [self calcHightWithString:unscrambleLabel];
    unscrambleLabel.frame = CGRectMake(10, 240, self.view.frame.size.width-20, _desLblHeight);
    [self.baseView addSubview:unscrambleLabel];
    
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(unscrambleLabel.mas_bottom).offset(10);
    }];
    
}

//计算文本label的高度
- (CGFloat)calcHightWithString:(UILabel *)label{
    return  [label.text boundingRectWithSize:CGSizeMake(label.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.height;
}




- (void)shuju{
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    //    label.backgroundColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"机构评级-日K线";
    label.font = [UIFont boldSystemFontOfSize:13];
    [self.baseView addSubview:label];
    
    NSMutableArray *priceArray = [NSMutableArray array];
    NSMutableArray *dateArray = [NSMutableArray array];
    
    for (BDDiagnoseModel *dModel in _dataArray) {
        [priceArray addObject:dModel.CLS_PRC];
    }
    for (int i = 0; i<_dataArray.count; i++) {
        if ( i% (_dataArray.count/4) == 0) {
            [dateArray addObject:[(BDDiagnoseModel *)_dataArray[i] TRD_DT]];
        }
    }
    
}



- (void)graphView{
    if (_chartView) {
        [_chartView removeFromSuperview];
        _chartView = nil;
    }
    CGRect frame = CGRectMake(10, 30, [UIScreen mainScreen].bounds.size.width - 20, 170);
    _chartView = [[SCChart alloc] initwithSCChartDataFrame:frame
                                                withSource:self
                                                 withStyle:SCChartLineStyle];
    [_chartView showInView:self.baseView];
    
}

- (NSArray *)getXTitles:(NSInteger )num {
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        NSString * str = [(BDDiagnoseModel *)_dataArray[i] TRD_DT];
//        if ( i% (_dataArray.count/4) == 0) {
            [xTitles addObject:str];
//        }
    }
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)SCChart_xLableArray:(SCChart *)chart {
    return [self getXTitles:_dataArray.count];
}

//数值多重数组
- (NSArray *)SCChart_yValueArray:(SCChart *)chart {
    NSMutableArray *priceArray = [NSMutableArray array];
    for (BDDiagnoseModel *dModel in _dataArray) {
        [priceArray addObject:dModel.CLS_PRC];
    }
    return @[priceArray];
}

#pragma mark -- SCChartDataSource
- (NSArray *)MySCChart_RatArray:(SCChart *)chart{
    _ratAry = [NSMutableArray array];
    for (BDDiagnoseModel *dModel in _dataArray) {
        [_ratAry addObject:dModel.RAT_CODE];
    }
//    NSLog(@"22>>%@",_ratAry);
    return _ratAry;
    
}


//判断显示横线条
- (BOOL)SCChart:(SCChart *)chart ShowHorizonLineAtIndex:(NSInteger)index {
    return YES;
}



//判断显示最大最小值
- (BOOL)SCChart:(SCChart *)chart ShowMaxMinAtIndex:(NSInteger)index {
    return YES;
}




-(void)setXLabels:(NSMutableArray *)xLabels
{
    _xLabels = xLabels;
    CGFloat num = 0;
    if (xLabels.count<=1){
        num=1.0;
    }else{
        num = xLabels.count;
    }
    _xLabelWidth = (self.baseView.frame.size.width - 30)/num;
    
    for (int i=0; i<xLabels.count; i++) {
        NSString *labelText = xLabels[i];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(i * _xLabelWidth+30, self.baseView.frame.size.height - 10, _xLabelWidth, 10)];
        label.text = labelText;
        [self.baseView addSubview:label];
    }
    
}


- (void)noDataView{
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, 30, self.view.frame.size.width, 25);
    //    label.backgroundColor = [UIColor cyanColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"暂时没有数据";
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
