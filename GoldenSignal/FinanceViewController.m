//
//  FinanceViewController.m
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FinanceViewController.h"//财务
#import "BDDiagnoseContentService.h"
#import "BDDiagnoseModel.h"
//#import "SCChart.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

#import "BarView.h"

#import "SCChartLabel.h"
#import "SCTool.h"

@interface FinanceViewController ()
{
    NSMutableArray *_dataArray;
    NSMutableArray *_dataArray2;
    BDDiagnoseContentService *_diagnoseService;
    CGFloat _desLblHeight;
    
    NSMutableArray *_valueArray;//值
    NSMutableArray *_dateArray;//年份
    
    UIView *_barView;
    
    CGPoint _coordinatePoint;//坐标原点
    float _scaleUnit;//比例单位
    float _value_long;
    
    float _maxValue;
    float _minValue;
}

@end

@implementation FinanceViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor  =[UIColor whiteColor];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
    
    self.baseView = [[UIView alloc]init];
    self.baseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.baseView];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(320);
    }];
//    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.view.frame.size.height - 449);
//    }];

    
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    
    
    
    _valueArray = [NSMutableArray array];
    _dateArray = [NSMutableArray array];
    
    
    
    
    
    [self getData];
    
}

#pragma mark :加载网络数据
- (void)getData{
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray2 = [[NSMutableArray alloc]init];
    _diagnoseService = [[BDDiagnoseContentService alloc]init];
    
    dispatch_queue_t requestQueue = dispatch_queue_create("RequestData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(requestQueue , ^{//异步请求
        
        
        _dataArray = [_diagnoseService getDiagnoseEachPageWithPageId:1599 andBD_CODE:self.BD_CODE];
        _dataArray2 = [_diagnoseService getDiagnoseEachPageWithPageId:1604 andBD_CODE:self.BD_CODE];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            _dataArray = nil;
            if (_dataArray == nil || _dataArray.count == 0) {
                [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.view.frame.size.height - 449+100);
                }];
                self.view.backgroundColor = [UIColor whiteColor];
                [self noDataView];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                return;
            }
            
            for (BDDiagnoseModel * dModel in _dataArray) {
                NSString *valueStr = dModel.NET_PROF_PCO;
                [_valueArray addObject:valueStr];
                NSString *yearStr = dModel.END_DT;
                [_dateArray addObject:yearStr];
            }
            
            // 相当于主线程中执行
            [self maxAndMinValue];
            [self barGraphView];
            [self unscrambleView];
            
            [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                //                            make.height.mas_equalTo(300);
                make.top.left.right.equalTo(self.baseView);
                make.bottom.equalTo(self.baseView);
            }];
            
            [self.view layoutIfNeeded];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"11>>>%lf,%lf",self.baseView.frame.size.height,self.view.frame.size.height);
            
        });
    });
    
    
}

#pragma mark :最大值、最小值 And X、Y轴
- (void)maxAndMinValue{
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 27)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"净利润（万元）";
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor blackColor];
    [self.baseView addSubview:label];
    
    CGRect frame = CGRectMake(10, 30, [UIScreen mainScreen].bounds.size.width - 20, 190);
    _barView = [[UIView alloc]initWithFrame:frame];
    
    [self.baseView addSubview:_barView];
    
    NSLog(@">>%@,%@",_valueArray,_dateArray);
    
    _maxValue=[[_valueArray valueForKeyPath:@"@max.floatValue"] floatValue];
    _minValue=[[_valueArray valueForKeyPath:@"@min.floatValue"] floatValue];
    
    float yZhouZheng = 0.0;
    
    float yRange = 0.0;//y轴范围
    if (_maxValue>=0 && _minValue <=0) {
        yRange = _maxValue-_minValue;
        float danWei = (190-20)/yRange;///每单位长度 包含有多少值Value
        yZhouZheng = _maxValue*danWei;/// Y轴正方向 上方 长度
        _coordinatePoint = CGPointMake(40, _barView.frame.origin.y + yZhouZheng);//在self.view的点
    }
    else if (_maxValue>=0 && _minValue >=0) {
        yRange = _maxValue-0 ;
        _coordinatePoint = CGPointMake(40, _barView.frame.origin.y+_barView.frame.size.height-20);//在self.view的点
    }
    else if (_maxValue<=0 && _minValue <=0) {
        yRange = 0-_minValue ;
        _coordinatePoint = CGPointMake(40, 0);//在self.view的点
    }
    
    _scaleUnit = (190-20)/yRange;///    长度/数值
    
    _value_long = yRange/(170-20);///每单位长度 包含有多少值Value   比例数值/单位长度
    
    DEBUGLog(@"zero=%lf",_coordinatePoint.y);
    
    
    UILabel *xLine = [[UILabel alloc]initWithFrame:CGRectMake(40, _coordinatePoint.y-30, _barView.frame.size.width-50, 1.0)];
    xLine.backgroundColor = [UIColor darkGrayColor];
    [_barView addSubview:xLine];
    
    UILabel *yLine = [[UILabel alloc]initWithFrame:CGRectMake(40, -8, 1.0, _barView.frame.size.height - 12)];
    yLine.backgroundColor = [UIColor darkGrayColor];
    [_barView addSubview:yLine];
    
    
    
    [self addYVabelValue];
}


#pragma mark :柱状条形图
- (void)barGraphView{
    
    NSInteger barCount = _valueArray.count;
    CGFloat width = (_barView.frame.size.width-50)/barCount;
    for (int i = 0; i<_valueArray.count; i++) {
        //条bar
        UILabel *barLabel = [[UILabel alloc]init];
        barLabel.frame = CGRectMake(50+i*width, _coordinatePoint.y-30 , 28, - [_valueArray[i] floatValue]*_scaleUnit);
        DEBUGLog(@"yV->%lf",[_valueArray[i] floatValue]);
        if ([_valueArray[i] floatValue]>0) {
            barLabel.backgroundColor = [UIColor redColor];
        }else {
            barLabel.backgroundColor = [UIColor greenColor];
        }
        [_barView addSubview:barLabel];
        
        //年份
        UILabel *yearLabel = [[UILabel alloc]init];
        yearLabel.frame = CGRectMake(50+i*width, 175 , 31, 15);
        yearLabel.text = _dateArray[i];
        yearLabel.font = [UIFont systemFontOfSize:13];
        [_barView addSubview:yearLabel];
    }
    
}

#pragma mark : 增加Y轴左侧对应的数据
- (void)addYVabelValue{
    ///计算坐标 算坐标比较麻烦
    int count = 4;
    float meiDuanZhi = 0.0;
    
    float yZhouZheng = 0.0;
    
    float yRange = 0.0;//y轴范围
    if (_maxValue>=0 && _minValue <=0) {
        yRange = _maxValue-_minValue;
        float danWei = (190-20)/yRange;///每单位长度 包含有多少值Value
        yZhouZheng = _maxValue*danWei;/// Y轴正方向 上方 长度
        _coordinatePoint = CGPointMake(40, _barView.frame.origin.y + yZhouZheng);//在self.view的点
        meiDuanZhi = yRange/count;
    }
    else if (_maxValue>=0 && _minValue >=0) {
        yRange = _maxValue-0 ;
        _coordinatePoint = CGPointMake(40, _barView.frame.origin.y+_barView.frame.size.height-20);//在self.view的点
        meiDuanZhi = yRange/count;
    }
    else if (_maxValue<=0 && _minValue <=0) {
        yRange = 0-_minValue ;
        _coordinatePoint = CGPointMake(40, 0);//在self.view的点
        meiDuanZhi = yRange/count;
    }
    
    _scaleUnit = (190-20)/yRange;///    长度/数值
    
    _value_long = yRange/(170-20);///每单位长度 包含有多少值Value   比例数值/单位长度
    
    DEBUGLog(@"zero=%lf",_coordinatePoint.y);
    
    float jianGe = yRange/count *_scaleUnit;//Y轴左侧数据之间的间隔值
    
    
    if (_maxValue >=0) {//X轴上方
        for (int i = 0; i<=count; i++) {
            if ((_coordinatePoint.y-30 - jianGe*i) >=0-8 ) {///保证不超出边界
                UILabel *label = [[UILabel alloc]init];
                label.font = [UIFont systemFontOfSize:9.0];
                label.textAlignment = NSTextAlignmentCenter;
                
                label.frame = CGRectMake(0, (_coordinatePoint.y-30 - jianGe*i), 40, 10);
                //                label.text = [NSString stringWithFormat:@"%.0fk",(level * i+_yValueMin)/1000];
                float floatText = meiDuanZhi*i/1000;
                NSString *temp;
                if (floatText >= 100 && floatText < 1000) {
                    temp = [NSString stringWithFormat:@"%.0f0k",floatText/10];
                }
                else if (floatText >=1000) {
                    temp = [NSString stringWithFormat:@"%.0f00k",floatText/100];
                }
                else {
                    temp  = [NSString stringWithFormat:@"%.0fk",floatText];
                }
                label.text = temp;
                [_barView addSubview:label];
                
                if (i != 0 ){
                    UILabel *xLine2 = [[UILabel alloc]initWithFrame:CGRectMake(40, (_coordinatePoint.y-30 - jianGe*i), _barView.frame.size.width-50, 1.0)];
                    xLine2.backgroundColor = [UIColor lightGrayColor];
                    [_barView addSubview:xLine2];
                }
            }
        }
    }
    
    if (_minValue <=0) {//X轴下方
        for (int i = 1; i<=count; i++) {
            if ((_coordinatePoint.y-30 + jianGe*i) < _barView.frame.size.height - 20) {///保证不超出边界
                UILabel *label = [[UILabel alloc]init];
                label.font = [UIFont systemFontOfSize:9.0];
                label.textAlignment = NSTextAlignmentCenter;
                
                label.frame = CGRectMake(0, (_coordinatePoint.y-30 + jianGe*i), 40, 10);
                //                label.text = [NSString stringWithFormat:@"-%gk",(level * i+_yValueMin)/1000];
                float floatText = meiDuanZhi*i/1000;
                NSString *temp;
                if (floatText >= 100 && floatText < 1000) {
                    temp = [NSString stringWithFormat:@"-%.0f0k",floatText/10];
                }
                else if (floatText >=1000) {
                    temp = [NSString stringWithFormat:@"-%.0f00k",floatText/100];
                }
                else {
                    temp  = [NSString stringWithFormat:@"-%.0fk",floatText];
                }
                label.text = temp;
                [_barView addSubview:label];
                
                
                UILabel *xLine2 = [[UILabel alloc]initWithFrame:CGRectMake(40, (_coordinatePoint.y-30 + jianGe*i), _barView.frame.size.width-50, 1.0)];
                xLine2.backgroundColor = [UIColor lightGrayColor];
                [_barView addSubview:xLine2];
            }
        }
    }
}

///DECStr	__NSCFString *	@"公司2014-12-31财报显示：\n盈利能力很强，每股收益2.2200元，净资产收益率17.78%；目前具有较好成长性，连续3年保持盈利增长；负债很重，资产负债率93.34%。"	0x00007f97db90ded0
#pragma mark : 财务解读view
- (void)unscrambleView{
    CGRect frame = CGRectMake(10, 230, self.view.frame.size.width-20, 16);
    UILabel *unscrambleLabel = [[UILabel alloc]initWithFrame:frame];
//    unscrambleLabel.backgroundColor = [UIColor yellowColor];
    unscrambleLabel.numberOfLines = 0;
    unscrambleLabel.font = [UIFont systemFontOfSize:13];
    unscrambleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    //赋值
    NSString *DECStr = nil;
    if (_dataArray2.count != 0) {
        for (BDDiagnoseModel * dModel in _dataArray2) {
            DECStr = dModel.DES;
            DECStr = [DECStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            DECStr = [DECStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
    } else {
        DECStr = @"暂无相关描述信息";
    }
    unscrambleLabel.text = DECStr;
    _desLblHeight = [self calcHightWithString:unscrambleLabel];
    unscrambleLabel.frame = CGRectMake(10, 230, self.view.frame.size.width-20, _desLblHeight);
    [self.baseView addSubview:unscrambleLabel];
    
    [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(unscrambleLabel.mas_bottom).offset(10);
        NSLog(@"0000>>>%lf,%lf",self.baseView.frame.size.height,self.view.frame.size.height);
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
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark :unUsed 增加Y轴左侧对应的数据，只用到了前半部分的Text算法 unUsed
-(void)setYLabels:(NSArray *)yLabels
{
    CGFloat max = 0;
    CGFloat min = 1000000000;
    NSInteger rowCount = 0; // 自动计算每个图表适合的行数
    for (NSString *valueString in _valueArray) {
        CGFloat value = [valueString floatValue];
        if (value > max) {
            max = value;
        }
        if (value < min) {
            min = value;
        }
    }
    if (self.showRange) {
        _yValueMin = min;
    }else{
        _yValueMin = 0;
    }
    _yValueMax = max;
    
    if (_chooseRange.max!=_chooseRange.min) { // 自定义数值范围
        _yValueMax = _chooseRange.max;
        _yValueMin = _chooseRange.min;
    } else { // 自动计算数值范围和合适的行数
        rowCount = [SCTool rowCountWithValueMax:_yValueMax] == 0 ? 5 : [SCTool rowCountWithValueMax:_yValueMax];
        _yValueMax = [SCTool rangeMaxWithValueMax:_yValueMax] == 0 ? 100 : [SCTool rangeMaxWithValueMax:_yValueMax];
        _yValueMin = 0;
    }
    
    float level = (_yValueMax-_yValueMin) /rowCount; // 每个区间的差值
    CGFloat chartCavanHeight = _barView.frame.size.height - UULabelHeight*3;
    CGFloat levelHeight = chartCavanHeight /rowCount; // 每个区间的高度
    
    for (int i=0; i<rowCount+1; i++) {
        SCChartLabel * label = [[SCChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight-i*levelHeight+5, UUYLabelwidth, UULabelHeight)];
        label.text = [NSString stringWithFormat:@"%g",level * i+_yValueMin];
        //        [_barView addSubview:label];
    }
    
    
    
    
    ///////////////////要用Text算法
    
    ///计算坐标 算坐标比较麻烦
    int count = 4;
    float meiDuanZhi = 0.0;
    
    float yZhouZheng = 0.0;
    
    float yRange = 0.0;//y轴范围
    if (_maxValue>=0 && _minValue <=0) {
        yRange = _maxValue-_minValue;
        float danWei = (190-20)/yRange;///每单位长度 包含有多少值Value
        yZhouZheng = _maxValue*danWei;/// Y轴正方向 上方 长度
        _coordinatePoint = CGPointMake(40, _barView.frame.origin.y + yZhouZheng);//在self.view的点
        meiDuanZhi = yRange/count;
    }
    else if (_maxValue>=0 && _minValue >=0) {
        yRange = _maxValue-0 ;
        _coordinatePoint = CGPointMake(40, _barView.frame.origin.y+_barView.frame.size.height-20);//在self.view的点
        meiDuanZhi = yRange/count;
    }
    else if (_maxValue<=0 && _minValue <=0) {
        yRange = 0-_minValue ;
        _coordinatePoint = CGPointMake(40, 0);//在self.view的点
        meiDuanZhi = yRange/count;
    }
    
    _scaleUnit = (190-20)/yRange;///    长度/数值
    
    _value_long = yRange/(170-20);///每单位长度 包含有多少值Value   比例数值/单位长度
    
    DEBUGLog(@"zero=%lf",_coordinatePoint.y);
    
    float jianGe = yRange/count *_scaleUnit;//Y轴左侧数据之间的间隔值
    
    
    if (_maxValue >=0) {//X轴上方
        for (int i = 0; i<=count; i++) {
            if ((_coordinatePoint.y-30 - jianGe*i) >=0-5 ) {///保证不超出边界
                UILabel *label = [[UILabel alloc]init];
                label.font = [UIFont systemFontOfSize:9.0];
                label.textAlignment = NSTextAlignmentCenter;
                
                label.frame = CGRectMake(0, (_coordinatePoint.y-30 - jianGe*i), 40, 10);
                //                label.text = [NSString stringWithFormat:@"%.0fk",(level * i+_yValueMin)/1000];
                float floatText = meiDuanZhi*i/1000;
                NSString *temp;
                if (floatText > 100) {
                    temp = [NSString stringWithFormat:@"%.0f00k",floatText/100];
                } else {
                    temp  = [NSString stringWithFormat:@"%.0fk",floatText];
                }
                label.text = temp;
                [_barView addSubview:label];
                
                if (i != 0 ){
                    UILabel *xLine2 = [[UILabel alloc]initWithFrame:CGRectMake(40, (_coordinatePoint.y-30 - jianGe*i), _barView.frame.size.width-50, 1.0)];
                    xLine2.backgroundColor = [UIColor lightGrayColor];
                    [_barView addSubview:xLine2];
                }
            }
        }
    }
    
    if (_minValue <=0) {//X轴下方
        for (int i = 1; i<=count; i++) {
            if ((_coordinatePoint.y-30 + jianGe*i) < _barView.frame.size.height - 20) {///保证不超出边界
                UILabel *label = [[UILabel alloc]init];
                label.font = [UIFont systemFontOfSize:9.0];
                label.textAlignment = NSTextAlignmentCenter;
                
                label.frame = CGRectMake(0, (_coordinatePoint.y-30 + jianGe*i), 40, 10);
                //                label.text = [NSString stringWithFormat:@"-%gk",(level * i+_yValueMin)/1000];
                float floatText = meiDuanZhi*i/1000;
                NSString *temp;
                if (floatText > 100) {
                    temp = [NSString stringWithFormat:@"-%.0f00k",floatText/100];
                } else {
                    temp  = [NSString stringWithFormat:@"-%.0fk",floatText];
                }
                label.text = temp;
                [_barView addSubview:label];
                
                
                UILabel *xLine2 = [[UILabel alloc]initWithFrame:CGRectMake(40, (_coordinatePoint.y-30 + jianGe*i), _barView.frame.size.width-50, 1.0)];
                xLine2.backgroundColor = [UIColor lightGrayColor];
                [_barView addSubview:xLine2];
            }
        }
    }
    
    
    
    
}


@end
