//
//  NewStockTableViewController.m
//  GoldenSignal
//
//  Created by CBD on 7/8/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <MBProgressHUD.h>
#import <MJRefresh.h>

#import "NewStockViewController.h"
#import "NewStockTableViewCell.h"
#import "newStockDetailViewController.h"
#import "BDImportService.h"
#import "BDNewStockModel.h"//Model
#import "NSDate+Utility.h"
#import "ImportsTableViewCell.h"

#define DFMainScreen self.view.frame.size

@interface NewStockViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArray;
    int _pageId;//每个页面的id 新股的是1590
    id _temp;//标记
    
    NSMutableArray *_subscribeArray;//分区头部数组
    NSMutableDictionary *_dataDictionary;
    
    UITableView *_tableVieww;
}

@end

@implementation NewStockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:[self middleTitleView]];
    
    _tableVieww = [[UITableView alloc]init];
    _tableVieww.frame = CGRectMake(0, 36, CGRectGetWidth(self.view.frame), self.view.frame.size.height - 180);
    _tableVieww.dataSource = self;
    _tableVieww.delegate = self;
    _tableVieww.rowHeight = 50;
    [self.view addSubview:_tableVieww];
    [_tableVieww registerNib:[UINib nibWithNibName:@"NewStockTableViewCell" bundle:nil] forCellReuseIdentifier:@"nstvcell"];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
    self.pageNumbs = 10;
    
    [self performSelectorInBackground:@selector(getImportNewStockRequestData) withObject:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (instancetype)initWithPageId:(int)pageId{
    self = [super init];
    if (self) {
        _pageId = pageId;
    }
    return self;
}

- (void)getImportNewStockRequestData{
    _dataArray = [NSMutableArray array];
    BDImportService *service = [[BDImportService alloc] init];
    
    _dataArray = [service getImportNewStockRequestDataWithPageId:_pageId];
    
    DEBUGLog(@"Debug:ary>%@",_dataArray);;
    if (_dataArray == nil) {
        [self creatOtherView];
        return;
    }else {
        [self resolveArrays];
    }
    [_tableVieww performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark  -- 分解开的数据
- (void)resolveArrays{
    //取到申购日放到数组中；
    NSMutableArray *subscribeDayAry = [NSMutableArray array];
    for (int i=0; i<_dataArray.count; i++) {
        BDNewStockModel *subDic = _dataArray[i];//这里取出Model对应的数据
        [subscribeDayAry addObject: subDic.SUB_BGN_DT_ON1];
    }
    
    //过滤数组
    NSSet *set = [NSSet setWithArray:subscribeDayAry];
    //过滤完的集合放入熄灯呢数组中，作为Section的数据源
    NSArray *subscribeArray = [set allObjects];
    //排序 从大到小
    NSArray *sortArray = @[[[NSSortDescriptor alloc]initWithKey:nil ascending:NO]];
    //最终的Section数据源
    subscribeArray = [set sortedArrayUsingDescriptors:sortArray];
    _subscribeArray = [NSMutableArray arrayWithArray:subscribeArray];
    
    
    NSMutableDictionary *dicts = [NSMutableDictionary dictionary];
    for (int i=0; i<_subscribeArray.count; i++) {
        //分段数组
        NSMutableArray *disjunctionArray = [[NSMutableArray alloc]init];
        //分区标题日期
        NSDate *sectionTitle = _subscribeArray[i];
        
        for (int j=0; j<_dataArray.count; j++) {
            BDNewStockModel *subsModel = _dataArray[j];
            NSDate *tempObj = ((BDNewStockModel *)_dataArray[j]).SUB_BGN_DT_ON1;
            //如果总数据数组里的某个时间 与 分区头部 某个时间相同
            //就把本组数据加入到一个新的 分段数组中
            if ([tempObj isEqual:sectionTitle] ) { //isEqualToDate:sectionTitle
                [disjunctionArray addObject: subsModel];
                DEBUGLog(@"Debug:aa %@",subsModel);
            }
            DEBUGLog(@"00Debug:%@",disjunctionArray);
        }
        [dicts setValue:disjunctionArray forKey:[sectionTitle toString:@"yyyy-MM-dd"]];
        _dataDictionary = dicts;
    }
}

#pragma mark  -- 如果没有数据，界面显示“近期无IPO新股申购”
- (void)creatOtherView{
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake((self.view.frame.size.width-150)/2, 15, 150, 25);
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"近期无IPO新股申购";
    [_tableVieww addSubview:label];
}

#pragma mark  -- 顶部标题
- (UIView *)middleTitleView {
    NSArray *titlesAry = @[@"申购新股",@"发行价/\n摊薄PE",@"上限/总量\n（万股）",@"中签日"];
    UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 36)];
    middleView.backgroundColor = RGB(199, 218, 241, 1);
    CGRect mainFrame = self.view.frame;
    UILabel *_titleLabel;
    for (int i=0; i<titlesAry.count; i++) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10+(mainFrame.size.width/4)*i, 0, mainFrame.size.width/4-20, 36)];
        //        _titleLabel.backgroundColor = [UIColor yellowColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = titlesAry[i];
        [middleView addSubview:_titleLabel];
    }
    return middleView;
}

#pragma mark -- delegate 各个分区头部

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_dataDictionary allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *str = [_subscribeArray[section] toString:@"yyyy-MM-dd"];
    NSMutableArray *sectionArray = [_dataDictionary objectForKey:str];
    return  sectionArray.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSString *str = [_subscribeArray[section] toString:@"yyyy-MM-dd"];
//    return str;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *headView = (UITableViewHeaderFooterView *)view;
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    tempLabel.backgroundColor = RGB(217, 217, 217, 1);
    [headView addSubview:tempLabel];
    DEBUGLog(@"Debug:cccc %@",[_subscribeArray[section] class]);//date
    
//    NSString *str = [_subscribeArray[section] toString:@"yyyy-MM-dd EEEE"];
    
    
    NSArray *weekdayAry = [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二",@"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSDateFormatter *formater =[[NSDateFormatter alloc] init];
    [formater setDateFormat:NSLocalizedString(@"yyyy-MM-dd EEEE",nil)];
    [formater setShortWeekdaySymbols:weekdayAry];
    [formater setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    
    NSString *endStr= [formater stringFromDate:_subscribeArray[section]];
    
    tempLabel.text = [NSString stringWithFormat:@"  %@ 申购",endStr];
    
    
    if (_dataArray.count == 0){
        tempLabel.text = @"";
        headView.hidden = YES;
    }
    view.tintColor = [UIColor lightGrayColor];
    tempLabel.font = [UIFont systemFontOfSize:14];
    tempLabel.textColor = RGB(43, 176, 241, 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewStockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nstvcell"];
    if (!cell) {
        cell = [[NewStockTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nstvcell"];
    }
    NSString *str = [_subscribeArray[indexPath.section] toString:@"yyyy-MM-dd"];
    NSMutableArray *sectionArray = [_dataDictionary objectForKey:str];//取到当前分区对应的数组
    
    BDNewStockModel *nsModel = sectionArray[indexPath.row];//取得当前行对应的数据
    DEBUGLog(@"Debug:ssssss  %@", nsModel.ISS_SHR);
    
    [cell showNewStockCellAndModel:nsModel];


    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *str = [_subscribeArray[indexPath.section] toString:@"yyyy-MM-dd"];
    NSMutableArray *sectionArray = [_dataDictionary objectForKey:str];//取到当前分区对应的数组
    
    BDNewStockModel *nsModel = sectionArray[indexPath.row];//取得当前行对应的数据
    
    newStockDetailViewController *detailVC = [[newStockDetailViewController alloc] initWithStockConnectId:nsModel.SECU_ID];
    detailVC.connectId = nsModel.SECU_ID;
    
    //获取UIView的父层UIViewController
    id object = [self nextResponder];
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    UIViewController *uc=(UIViewController*)object;
    [uc.navigationController pushViewController:detailVC animated:YES];
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
