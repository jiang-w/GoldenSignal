//
//  QuoteIndexViewController.m
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/15/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "IndexQuoteViewController.h"//行情指数页
#import "IdxQuoteViewCell.h"
#import "BDSectService.h"

#import <MBProgressHUD.h>

@interface IndexQuoteViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    long _indexId;
    NSArray *_indexArray;
    NSArray *_indexArray2;
    BOOL _asc;
    dispatch_queue_t loadDataQueue;
    UITableView *_tableVieww;
    
    UILabel *_firstLabel;
}
@end

@implementation IndexQuoteViewController

- (id)initWithIndexId:(long)IndexId{
    self = [super init];
    if (self) {
        _indexId = (long)IndexId;
        loadDataQueue = dispatch_queue_create("loadData", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _tableVieww = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.frame), self.view.frame.size.height - 164)];
    
    _tableVieww.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_tableVieww];
    _tableVieww.dataSource = self;
    _tableVieww.delegate = self;
    _tableVieww.bounces = NO;
    _tableVieww.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    
    dispatch_async(loadDataQueue, ^{
        NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadSortedSecuCodes) userInfo:nil repeats:YES];
        [time fire];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });
    
    _asc = NO;
   
    [self.view addSubview:[self middleTitleView]];
}




- (void)loadSortedSecuCodes {
    BDSectService *service = [[BDSectService alloc] init];
    //100839  101202
    _indexArray = [service getSecuCodesBySectId:100839 andCodes:nil sortByIndicateName:nil ascending:_asc];

    _indexArray2 = [service getSecuCodesBySectId:101202 andCodes:nil sortByIndicateName:nil ascending:_asc];

    if (_indexArray.count > 0 || _indexArray2.count >0) {
        [_tableVieww performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



- (UIView *)middleTitleView{
    NSArray *titlesAry = @[@"涨幅%↓",@"指标",@"分时",@"K线",@"金信号"];
    UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];

    CGRect mainFrame = self.view.frame;
    UILabel *_titleLabel;
    for (int i=0; i<titlesAry.count; i++) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10+(mainFrame.size.width/5)*i, 0, mainFrame.size.width/5-10, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = RGB(249, 191, 0);
        _titleLabel.userInteractionEnabled = YES;
        
        _titleLabel.text = titlesAry[i];
        if (i==0) {
            _firstLabel = _titleLabel;
        }
        
        [middleView addSubview:_titleLabel];
        _titleLabel.tag = 10+i;
        if (i == 0) {
            UIButton *_btn = [UIButton buttonWithType:UIButtonTypeSystem];
            //            _btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, mainFrame.size.width/5-10, 26)];
            _btn.backgroundColor = [UIColor clearColor];
            _btn.frame = _titleLabel.frame;
            [_btn addTarget:self action:@selector(clickSort) forControlEvents:UIControlEventTouchUpInside];
            [_titleLabel addSubview:_btn];
        }
    }
    return middleView;
}


- (void)clickSort {
    _asc = !_asc;
    if (_asc == YES) {
        _firstLabel.text = @"涨幅%↑";
    }
    else {
        _firstLabel.text = @"涨幅%↓";
    }
    DEBUGLog(@"Debug: %d",_asc);
    [self loadSortedSecuCodes];
}

#pragma mark -- delegate 各个分区头部
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (_indexArray == nil || _indexArray.count == 0) {
            return 0;
        }
    } else {
        if (_indexArray2 == nil || _indexArray2.count == 0) {
            return 0;
        }
    }
    return 20;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
    UITableViewHeaderFooterView *headView = (UITableViewHeaderFooterView *)view;
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    tempLabel.backgroundColor = [UIColor blackColor];
    [headView addSubview:tempLabel];
    if (section == 0) {
        tempLabel.text = @"常用指数";
//        if (_indexArray.count == 0){
//            tempLabel.text = @"";
//            headView.hidden = YES;
//        }
    } else if (section == 1){
        tempLabel.text = @"行业指数";
//        if (_indexArray2.count == 0){
//            tempLabel.text = @"";
//            headView.hidden = YES;
//        }
    }
    view.tintColor = [UIColor blackColor];
    tempLabel.font = [UIFont systemFontOfSize:14];
    tempLabel.textColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [_indexArray count] ? _indexArray.count : 0;
    } else {
        return [_indexArray2 count] ? _indexArray2.count : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        NSString *bdCode = [_indexArray objectAtIndex:indexPath.row];
        BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:bdCode];
        if (secu.typ == idx) {
            IdxQuoteViewCell *idxCell = (IdxQuoteViewCell *)[tableView dequeueReusableCellWithIdentifier:@"IdxQuoteCell"];
            if (idxCell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"IdxQuoteViewCell" owner:self options:nil];
                for (id obj in nib) {
                    if ([obj isKindOfClass:[IdxQuoteViewCell class]]) {
                        idxCell = (IdxQuoteViewCell *)obj;
                        break;
                    }
                }
            }
            idxCell.code = bdCode;
            cell = idxCell;
        }
        
    } else {
        NSString *bdCode2 = [_indexArray2 objectAtIndex:indexPath.row];
        BDSecuCode *secu2 = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:bdCode2];
        if (secu2.typ == idx) {
            IdxQuoteViewCell *idxCell = (IdxQuoteViewCell *)[tableView dequeueReusableCellWithIdentifier:@"IdxQuoteCell"];
            if (idxCell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"IdxQuoteViewCell" owner:self options:nil];
                for (id obj in nib) {
                    if ([obj isKindOfClass:[IdxQuoteViewCell class]]) {
                        idxCell = (IdxQuoteViewCell *)obj;
                        break;
                    }
                }
            }
            idxCell.code = bdCode2;
            cell = idxCell;
        }
    }
    
    cell.backgroundColor = (indexPath.row%2 == 0) ? RGB(30, 30, 30) :[UIColor blackColor];
        
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IdxQuoteViewCell *cell = (IdxQuoteViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectIndexCode:)]) {
        [self.delegate didSelectIndexCode:cell.code];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
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
