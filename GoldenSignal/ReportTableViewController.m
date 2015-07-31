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

#import "ReportDetailViewController1.h"//研报详情页面
#import "NewsDetailViewController.h"



@interface ReportTableViewController ()
{
    BDStockPoolInfoService *_infoService;
    NSMutableArray *_codeArray;
    NSMutableArray *_firstArray;
    NSMutableArray *_allArray;
    long _lastId;
    id _temp;
    NSUInteger _timeIndex;//次数
    UILabel *_label;
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
    self.tableView.rowHeight = 120;
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
//    _allArray = [[NSMutableArray alloc]init];
    
    self.pageNumbs = 10;
    _timeIndex = 1;
    _allArray = [[NSMutableArray alloc]init];
    [self getRequestDataResource2];
    [self refresh];
    
    _label = [[UILabel alloc]init];
    //    _label.backgroundColor = [UIColor yellowColor];
    _label.frame = CGRectMake(0, 30, self.view.frame.size.width, 25);
    _label.font = [UIFont systemFontOfSize:14];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:_label];
    _label.hidden  = YES;
}

- (void)getRequestDataResource2{
    _firstArray= [[NSMutableArray alloc]initWithCapacity:0];
    _codeArray = [[BDStockPool sharedInstance].codes copy];
    _infoService = [BDStockPoolInfoService new];
    
    //_innerId	long	1097587482	1097587482
    //判断上拉下拉刷新
    if (self.tableView.legendHeader.isRefreshing == YES) {
        _label.text = @"";
        _lastId = 0;
        _timeIndex = 1;
        self.pageNumbs =10;
    } else if (self.tableView.legendFooter.isRefreshing == YES) {
        _label.text = @"";
        _timeIndex ++;
        [self downPullRefresh];
        return;
//这是 数据条数变的时候 每次都重新请求一次，浪费性能
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
            _firstArray = (NSMutableArray *)[_infoService getReportListBySecuCode:_codeArray pageIndex:_timeIndex andPageSize:self.pageNumbs];
        }
        else if ([self.codeId isEqual:@"news"]) {
            _firstArray = [_infoService getNewsListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 相当于主线程中执行
            
            [self.tableView.legendHeader endRefreshing];
            [self.tableView.legendFooter endRefreshing];
            _temp = _firstArray.lastObject;
            _lastId = [_firstArray.lastObject innerId];
            _allArray = [NSMutableArray arrayWithArray:_firstArray];
            if (_codeArray.count == 0) {
                _label.hidden = NO;
                _label.text = @"请先添加自选股然后查看相关的数据";
            }
            else if (_allArray.count == 0) {
                _label.hidden = NO;
                _label.text = @"此栏目近期没有相关的数据";
            }
            else {
                _label.text = @"";
                _label.hidden = YES;
            }
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
            tempAry = (NSMutableArray *)[_infoService getReportListBySecuCode:_codeArray pageIndex:_timeIndex andPageSize:self.pageNumbs];
        }
        else if ([self.codeId isEqual:@"news"]) {
            tempAry = [_infoService getNewsListBySecuCodes:_codeArray lastId:_lastId quantity:self.pageNumbs];
        }
        [self.tableView.legendFooter endRefreshing];
        _lastId = [tempAry.lastObject innerId];
        _temp = tempAry.lastObject;
        [_allArray addObjectsFromArray:tempAry];
        if (_codeArray.count == 0) {
            _label.hidden = NO;
            _label.text = @"请先添加自选股然后查看相关的数据";
        }
        else if (_allArray.count == 0) {
            _label.hidden = NO;
            _label.text = @"此栏目近期没有相关的数据";
        }
        else {
            _label.text = @"";
            _label.hidden = YES;
        }
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
        BDReportList *rModel = _allArray[indexPath.row];
        ReportTableViewCell *ReportCell = [tableView dequeueReusableCellWithIdentifier:@"ReportNewsCell" ] ;
        //把Model里面解析出来的数据 加载到Cell里面
        [ReportCell showCellAndReportModel:rModel];
        ReportCell.tag = indexPath.row +100;
//        self.tableView.rowHeight = ReportCell.rowHeight;
        cell = ReportCell;
    }
    else if ([self.codeId isEqual:@"news"]) {
        BDNewsList *newsModel = _allArray[indexPath.row];
        newsTableViewCell *newsCell = [tableView dequeueReusableCellWithIdentifier:@"newsTableCell"];
        [newsCell showCellAndNewsModel:newsModel];
        newsCell.tag = indexPath.row + 200;
        cell = newsCell;
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([self.codeId isEqual:@"report"]) {
        ReportTableViewCell *ReportCell = (ReportTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        //这里计算Cell的高度时必须是 自适应lebel（多个）的高度和 加上 剩余其他控件的高度
//        [ReportCell layoutIfNeeded];
        return ReportCell.rowHeight;
    }
    else {
        newsTableViewCell *newsCell = (newsTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        
        [newsCell layoutIfNeeded];
        //        CGFloat cellH = [newsCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        CGFloat cellH = newsCell.titleHeight +newsCell.dataAndLabel.frame.size.height + newsCell.desHeight + 42;
//        DEBUGLog(@"11Debug:H%.2lf",cellH);
        return cellH;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat cellH = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
//    DEBUGLog(@"222222222Debug:H%.2lf",cellH);
//    return cellH;
    
    if ([self.codeId isEqual:@"report"]) {
        ReportTableViewCell *ReportCell = (ReportTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        if (ReportCell.priceLabel.hidden == YES) {
            return 137;
        } else{
            return 152;
        }
       
    } else {
        return 145;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.codeId isEqual:@"report"]) {
        BDReportList *rModel = _allArray[indexPath.row];
        ReportDetailViewController1 *detail = [[ReportDetailViewController1 alloc] init];
        detail.contentId = rModel.cont_id;
        detail.hidesBottomBarWhenPushed = YES;
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        
        [uc.navigationController pushViewController:detail animated:YES];
    }
    else if ([self.codeId isEqual:@"news"]) {
        BDNewsList *newsModel = _allArray[indexPath.row];
        NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
        detail.contentId = newsModel.connectId;
        detail.hidesBottomBarWhenPushed = YES;
        
        //获取UIView的父层UIViewController
        id object = [self nextResponder];
        while (![object isKindOfClass:[UIViewController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        UIViewController *uc=(UIViewController*)object;
        
        [uc.navigationController pushViewController:detail animated:YES];
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
