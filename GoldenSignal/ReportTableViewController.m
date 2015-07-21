//
//  ReportTableViewController.m
//  GoldenSignal
//
//  Created by CBD on 6/23/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "ReportTableViewController.h"
#import "BDStockPoolInfoService.h"
#import "ReportTableViewCell.h"
#import "newsTableViewCell.h"
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import <MJRefreshFooter.h>

#import "ReportDetailViewController.h"//研报详情页面
#import "NewsContentViewController.h"//新闻详情页面



@interface ReportTableViewController ()
{
    BDStockPoolInfoService *_infoService;
    NSMutableArray *_codeArray;
    NSMutableArray *_firstArray;
    NSMutableArray *_allArray;
    long _lastId;
    id _temp;
}

@end



@implementation ReportTableViewController

#pragma mark -- 刷新
- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf getRequestDataResource2];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf getRequestDataResource2];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addCustomStockChanged4:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(removeCustomStockChanged4:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
    
    //提前注册
    if ([self.codeId isEqual:@"report"]) {
        [self.tableView registerNib:[UINib nibWithNibName:@"ReportTableViewCell" bundle:nil] forCellReuseIdentifier:@"ReportNewsCell"];
    }
    else if ([self.codeId isEqual:@"news"]) {
        [self.tableView registerNib:[UINib nibWithNibName:@"newsTableViewCell" bundle:nil] forCellReuseIdentifier:@"newsTableCell"];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
//    _allArray = [[NSMutableArray alloc]init];
    
    self.pageNumbs = 10;
    _allArray = [[NSMutableArray alloc]init];
    [self getRequestDataResource2];
    [self refresh];
}

- (void)getRequestDataResource2{
    _firstArray= [[NSMutableArray alloc]initWithCapacity:0];
    _codeArray = [[BDStockPool sharedInstance].codes copy];
    _infoService = [BDStockPoolInfoService new];
    
    //_innerId	long	1097587482	1097587482
    //判断上拉下拉刷新
    if (self.tableView.legendHeader.isRefreshing == YES) {
        self.pageNumbs =10;
    } else if (self.tableView.legendFooter.isRefreshing == YES) {
        [self downPullRefresh];
        return;
//这是 数据条数变的时候 每次都重新请求一次，浪费流量
//        if (_temp == _allArray.lastObject) {
//            self.pageNumbs += 10;
//        } else {
//            return;
//        }
    }
//    DEBUGLog(@"2ar=%@,cou=%ld,2c=%d",_dataArray,_dataArray.count,self.pageNumbs);
    
#pragma mark --异步加载
    //创建队列
    dispatch_queue_t requestQueue = dispatch_queue_create("RequestData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(requestQueue , ^{//异步请求
        if ([self.codeId isEqual:@"report"]) {
            _firstArray = [_infoService getReportListBySecuCodes:_codeArray lastId:0 quantity:self.pageNumbs];
        }
        else if ([self.codeId isEqual:@"news"]) {
            _firstArray = [_infoService getNewsListBySecuCodes:_codeArray lastId:0 quantity:self.pageNumbs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 相当于主线程中执行
            
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
        if ([self.codeId isEqual:@"report"]) {
            tempAry = [_infoService getReportListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        else if ([self.codeId isEqual:@"news"]) {
            tempAry = [_infoService getNewsListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
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




- (void)addCustomStockChanged4:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"add"]) {
        [self getRequestDataResource2];
    }
}
- (void)removeCustomStockChanged4:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"remove"]) {
        [self getRequestDataResource2];
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if ([self.codeId isEqual:@"report"]) {
        BDReport *rModel = _allArray[indexPath.row];
        ReportTableViewCell *ReportCell = [tableView dequeueReusableCellWithIdentifier:@"ReportNewsCell" ] ;
        //把Model里面解析出来的数据 加载到Cell里面
        [ReportCell showCellAndReportModel:rModel];
        cell = ReportCell;
    }
    else if ([self.codeId isEqual:@"news"]) {
        BDNews *newsModel = _allArray[indexPath.row];
        newsTableViewCell *newsCell = [tableView dequeueReusableCellWithIdentifier:@"newsTableCell"];
        [newsCell showCellAndNewsModel:newsModel];
        cell = newsCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.codeId isEqual:@"report"]) {
        ReportTableViewCell *ReportCell = (ReportTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        //这里计算Cell的高度时必须是 自适应lebel（多个）的高度和 加上 剩余其他控件的高度
        CGFloat cellH = ReportCell.titleLabel.frame.size.height + ReportCell.dataAndLabel.frame.size.height + ReportCell.priceLabel.frame.size.height + ReportCell.descriLabel.frame.size.height;
        if (ReportCell.priceLabel.hidden == YES) {
            return cellH + 53 - 26;
        } else {
            return cellH + 53;
        }
    }
    else {
        newsTableViewCell *newsCell = (newsTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        CGFloat cellH = newsCell.titleLabel.frame.size.height + newsCell.dataAndLabel.frame.size.height + newsCell.newsDesLabel.frame.size.height ;
        return cellH + 48;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.codeId isEqual:@"report"]) {
        return 150;
    } else {
        return 115;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.codeId isEqual:@"report"]) {
        BDReport *rModel = _allArray[indexPath.row];
        ReportDetailViewController *RDVC = [[ReportDetailViewController alloc]initWithModel:rModel andConnectId:rModel.innerId];
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        
        [uc.navigationController pushViewController:RDVC animated:YES];
    }
    else if ([self.codeId isEqual:@"news"]) {
        BDNews *newsModel = _allArray[indexPath.row];
        NewsContentViewController *ONDVC = [[NewsContentViewController alloc]initWithModel:newsModel andId:newsModel.connectId andPageId:1588];
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        
        [uc.navigationController pushViewController:ONDVC animated:YES];
    }
    
    
}


// //////////////////////////////////////////////////////////////


- (void)nslog{
    //研报：NSLog(@"->%ld,%@,%@,%@,%@,%@,%lf,%@,%ld",pModel.innerId,pModel.title,pModel.date ,pModel.rating ,pModel.com ,pModel.aut ,pModel.targ_prc ,pModel.abst,pModel.sn);
    //1127139911,蓝色光标(300058)布局移动广告业务 营销产业王者归来,2015-06-09 16:00:00 +0000,强烈推荐,招商证券,王京乐,36.000000,移动端+大数据不断补强，占据移动端市场第一。亿动是移动广告业务中的领先企业，在移动广,0
    
    //新闻：NSLog(@"->%ld,%@,%@, %@, %@,%@, %@, %@,%@",pModel.innerId,pModel.title,pModel.date, pModel.abstract,pModel.content,pModel.author, pModel.media,pModel.imageUrl,pModel.labels);
    //1132285740,标的涉诉致大连控股(600747)重组失败,2015-06-16 16:00:00 +0000,
    //大连控股(600747)重组一波三折，最终因大股东资金往来纠纷涉及重组标的，公司决定,
    //(null),(null),
    //中国证券网,(null),()
}



//unuse
- (void)drawLayer2:(CALayer *)layer inContext:(CGContextRef)ctx{
    UILabel *testLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 320, 30)];
    
    testLabel.backgroundColor = [UIColor lightGrayColor];
    
    testLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"今天天气不错呀"];
    
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:17.0],
                               NSFontAttributeName,
                               [UIColor cyanColor],
                               NSForegroundColorAttributeName, nil];
    
    [AttributedStr addAttributes:attribute range:NSMakeRange(1, 2)];
    
    [AttributedStr setAttributes:attribute range:NSMakeRange(1, 2)];
    
    
    
    [AttributedStr addAttribute:NSFontAttributeName
     
                          value:[UIFont systemFontOfSize:17.0]
     
                          range:NSMakeRange(1, 2)];
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
     
                          value:[UIColor redColor]
     
                          range:NSMakeRange(2, 2)];
    
    testLabel.attributedText = AttributedStr;
    
    [self.view addSubview:testLabel];
}



@end
