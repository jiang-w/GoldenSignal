//
//  SectQuoteViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/1/27.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SectQuoteViewController.h"
#import "QuoteViewCell.h"
#import "IdxQuoteViewCell.h"
#import "BDSectService.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface SectQuoteViewController ()
{
    long _sectId;
    NSArray *_sectCodeArray;
    dispatch_queue_t loadDataQueue;
    BOOL _asc;
}
@end

@implementation SectQuoteViewController

- (id)initWithSectId:(long)sectId {
    self = [super init];
    if (self) {
        _sectId = sectId;
        loadDataQueue = dispatch_queue_create("loadData", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGB(29, 34, 40, 1);
    self.tableView.bounces = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;
    dispatch_async(loadDataQueue, ^{
        NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadSortedSecuCodes) userInfo:nil repeats:YES];
        [time fire];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });

    _asc = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSortedSecuCodes {
    BDSectService *service = [[BDSectService alloc] init];
    _sectCodeArray = [service getSecuCodesBySectId:_sectId andCodes:nil sortByIndicateName:nil ascending:_asc];
    if (_sectCodeArray.count > 0) {
        // 返回主线程刷新视图
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
//        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 26;
}

//系统方法设置标题视图，此方法Header不随cell移动
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSArray *titlesAry = @[@"涨幅%↓",@"指标",@"分时",@"K线",@"金信号"];
    UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake(0, 94, CGRectGetWidth(self.view.frame), 26)];
    middleView.backgroundColor = [UIColor blackColor];
    CGRect mainFrame = self.view.frame;
    UILabel *titleLabel;
    for (int i=0; i<titlesAry.count; i++) {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10+(mainFrame.size.width/5)*i, 0, mainFrame.size.width/5-10, 30)];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = RGB(249, 191, 0, 1);
        titleLabel.userInteractionEnabled = YES;
        titleLabel.text = titlesAry[i];
        [middleView addSubview:titleLabel];
        
        if (i == 0) {
            titleLabel.text = _asc == YES ? @"涨幅%↑" : titlesAry[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = titleLabel.frame;
            [btn addTarget:self action:@selector(clickSort) forControlEvents:UIControlEventTouchUpInside];
            [titleLabel addSubview:btn];
        }
    }
    return middleView;
}

- (void)clickSort {
    _asc = !_asc;
    [self loadSortedSecuCodes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sectCodeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *bdCode = [_sectCodeArray objectAtIndex:indexPath.row];
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:bdCode];
    if (secu != nil && secu.typ == idx) {
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
    else {
        QuoteViewCell *stockCell = (QuoteViewCell *)[tableView dequeueReusableCellWithIdentifier:@"QuoteCell"];
        if (stockCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QuoteViewCell" owner:self options:nil];
            for (id obj in nib) {
                if ([obj isKindOfClass:[QuoteViewCell class]]) {
                    stockCell = (QuoteViewCell *)obj;
                    break;
                }
            }
        }
        stockCell.code = bdCode;
        cell = stockCell;
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor blackColor];
    }
    else {
        cell.backgroundColor = RGB(30, 30, 30, 1);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QuoteViewCell *cell = (QuoteViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSecuCode:)]) {
        [self.delegate didSelectSecuCode:cell.code];
    }
}

@end
