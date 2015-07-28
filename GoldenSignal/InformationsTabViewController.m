//
//  TestTableViewController.m
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/16/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "InformationsTabViewController.h"
#import "BDStockPoolInfoService.h"
#import "InfomationsTableViewCell.h"
#import "PerformanceTableViewCell.h"
#import <CoreText/CoreText.h>
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import <AFNetworking.h>

#import "AnnouncementDetailViewController.h"//公告详情页面


@interface InformationsTabViewController ()
{
    NSMutableArray *_allArray;//最终的全部数据源数组
    NSMutableArray *_codeArray;
    NSMutableArray *_firstArray;
    BDStockPoolInfoService *_infoService;
    long _lastId;
    id _temp;
    
    NSUInteger _timeIndex;//次数
}

@end


@implementation InformationsTabViewController


- (id)initWithCodeId:(NSString *)codeId{
    self = [super init];
    if (self) {
//        _codeId = codeId;
//        _loadDataQueue = dispatch_queue_create("loadData", nil);
    }
    return self;
}

#pragma mark -- 刷新
- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf getRequestDataResource];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf getRequestDataResource];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addCustomStockChanged3:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(removeCustomStockChanged3:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];

    
    //提前注册
    if ([self.InformationId isEqual:@"tiShi"]) {
        [self.tableView registerNib:[UINib nibWithNibName:@"InfomationsTableViewCell" bundle:nil] forCellReuseIdentifier:@"InformationsCell"];
    }
    else {
        [self.tableView registerNib:[UINib nibWithNibName:@"PerformanceTableViewCell" bundle:nil] forCellReuseIdentifier:@"PerformanceCell"];
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
    
    _allArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.pageNumbs = 10;
    _timeIndex = 1;

    [self getRequestDataResource];
    [self refresh];
    //    [self performSelectorInBackground:@selector(getRequestDataResource) withObject:nil];
    //    [self performSelectorInBackground:@selector(refresh) withObject:nil];
}

- (void)getRequestDataResource{
    _firstArray= [[NSMutableArray alloc]init];
    _codeArray = [[BDStockPool sharedInstance].codes copy];
    _infoService = [BDStockPoolInfoService new];
    DEBUGLog(@"DEBUGLog1arr=>%@",_codeArray);
    //判断上拉下拉刷新
    if (self.tableView.legendHeader.isRefreshing == YES) {
        self.pageNumbs =10;
        _lastId = 0;
        _timeIndex = 1;
    }
    else if (self.tableView.legendFooter.isRefreshing == YES) {
        _timeIndex ++;
        [self downPullRefresh];
        return;
//        if (_temp == _allArray.lastObject) {
//            self.pageNumbs += 10;
//            _lastId = 0;
//        } else {
//            [self.tableView.legendFooter noticeNoMoreData];
//            return;
//        }
    }
//    DEBUGLog(@"DEBUGLog2ar=%@,cou=%ld,2c=%d",_codeArray,_codeArray.count,self.pageNumbs);

#pragma mark --异步加载
    dispatch_queue_t requestQueue = dispatch_queue_create("RequestData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(requestQueue , ^{
        if ([self.InformationId isEqual:@"tiShi"]) {
            _firstArray = [_infoService getPromptListBySecuCodes:_codeArray pageIndex:_timeIndex andPageSize:self.pageNumbs];
        }
        else if ([self.InformationId isEqual:@"gongGao"]) {
            _firstArray = [_infoService getBulletinListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        else if ([self.InformationId isEqual:@"yeJi"]) {
            _firstArray = [_infoService getPerformanceListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 返回主线程中执行
            [self.tableView.legendHeader endRefreshing];
            [self.tableView.legendFooter endRefreshing];
            _temp = _firstArray.lastObject;
            _lastId = [_firstArray.lastObject innerId];
            _allArray = [NSMutableArray arrayWithArray:_firstArray];
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}

//上拉刷新 这是每次都拼接固定的条数的方法
- (void)downPullRefresh{
    if (_temp == _allArray.lastObject) {
        NSMutableArray *tempAry = [[NSMutableArray alloc]init];
        if ([self.InformationId isEqual:@"tiShi"]) {
            tempAry = [_infoService getPromptListBySecuCodes:_codeArray pageIndex:_timeIndex andPageSize:self.pageNumbs];
        }
        else if ([self.InformationId isEqual:@"gongGao"]) {
            tempAry = [_infoService getBulletinListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        else if ([self.InformationId isEqual:@"yeJi"]) {
            tempAry = [_infoService getPerformanceListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        [self.tableView.legendFooter endRefreshing];
        _lastId = [tempAry.lastObject innerId];
        _temp = tempAry.lastObject;
        [_allArray addObjectsFromArray:tempAry];
        [self.tableView reloadData];
    } else {
        [self.tableView.legendFooter noticeNoMoreData];
        return;
    }
}

- (void)addCustomStockChanged3:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"add"]) {
        [self getRequestDataResource];
    }
}

- (void)removeCustomStockChanged3:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"remove"]) {
        [self getRequestDataResource];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allArray.count;
}

/* 信息
//  1126795616, 601968.SH, 601968, 宝钢包装, 2016-06-11有7500万限售股可上市流通(为发行前股份限售流通),                   2016-06-10 16:00:00 +0000,
//    NSLog(@"%ld,%@,%@, %@,%@,%@,",pModel.innerId,pModel.bdCode,pModel.trdCode, pModel.secuName,pModel.title,pModel.date);
//    NSString *str1 = [NSString stringWithFormat:@"【%@%@】",pModel.trdCode,pModel.secuName];
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self.InformationId isEqual:@"tiShi"]) {
        InfomationsTableViewCell *Infocell = [tableView dequeueReusableCellWithIdentifier:@"InformationsCell"];
        BDPrompt *pModel = _allArray[indexPath.row];
        [Infocell showTiShiCellAndModel:pModel];
        cell = Infocell;
    }
    else if ([self.InformationId isEqual:@"gongGao"]) {
        PerformanceTableViewCell *gongGaoCell = [tableView dequeueReusableCellWithIdentifier:@"PerformanceCell"];
//        gongGaoCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        BDAnnouncementList *pModel = _allArray[indexPath.row];
        [gongGaoCell showGongGaoCellAndModel:pModel];
        cell = gongGaoCell;
    }
    else if ([self.InformationId isEqual:@"yeJi"]) {
        PerformanceTableViewCell *PerformanceCell = [tableView dequeueReusableCellWithIdentifier:@"PerformanceCell"];
        BDPrompt *pModel = _allArray[indexPath.row];
        [PerformanceCell showYeJiCellAndModel:pModel];
        cell = PerformanceCell;
    }
    
    return cell;
}
//颜色值 61 177 241





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.InformationId isEqual:@"tiShi"]) {
        InfomationsTableViewCell *cell = (InfomationsTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        CGFloat cellH = cell.titleLabelHeight + cell.dateLabel.frame.size.height +30;
//        DEBUGLog(@"11Debug:H%.2lf",cellH);
        return cellH;
    } else {
        PerformanceTableViewCell *cell = (PerformanceTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//        CGFloat cellH = cell.title1.frame.size.height + cell.contentLabel.frame.size.height+30;
        return cell.cellRowHeight;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat cellH = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
//    DEBUGLog(@"2222Debug:H%.2lf",cellH);
//    return cellH;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.InformationId isEqual:@"gongGao"]) {
        BDAnnouncementList *bModel = _allArray[indexPath.row];
        AnnouncementDetailViewController *detail = [[AnnouncementDetailViewController alloc] init];
        detail.contentId = bModel.innerId;
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        [uc.navigationController pushViewController:detail animated:YES];
    } else {
        return;
    }
}



@end
