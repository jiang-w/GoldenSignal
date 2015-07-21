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
#import "BDImportService.h"
#import "BDNewStockModel.h"//Model

#import "ImportsTableViewCell.h"

#define DFMainScreen self.view.frame.size

@interface NewStockViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableVieww;
    NSMutableArray *_dataArray;
    NSMutableArray *_dataArray2;
    int _pageId;//每个页面的id 新股的是1590
    id _temp;//标记
    
    NSMutableArray *_subscribeArray;//分区头部数组
    NSMutableArray *_allArrays;//分解后的总数组
}

@end

@implementation NewStockViewController

- (instancetype)initWithPageId:(int)pageId{
    self = [super init];
    if (self) {
        _pageId = pageId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:[self middleTitleView]];
    _tableVieww = [[UITableView alloc]initWithFrame:CGRectMake(0, 36, CGRectGetWidth(self.view.frame), self.view.frame.size.height - 164)];
    [self.view addSubview:_tableVieww];
    _tableVieww.dataSource = self;
    _tableVieww.delegate = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;//透明度0 表示完全透明
    hud.activityIndicatorColor = [UIColor blackColor];
    self.pageNumbs = 10;
    
    
    [self performSelectorInBackground:@selector(getImportNewStockRequestData) withObject:nil];
    
//    [self resolveArrays];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)getImportNewStockRequestData{
    _dataArray = [NSMutableArray array];
    BDImportService *service = [[BDImportService alloc] init];
    
    _dataArray = [service getImportNewStockRequestDataWithPageId:_pageId lastCellId:0 quantity:self.pageNumbs];
    
    DEBUGLog(@"Debug:ary>%@",_dataArray);;
    if (_dataArray == nil) {
        [self creatOtherView];
        return;
    }else {
        [self resolveArrays];
    }
    
    [_tableVieww performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    
    //    DEBUGLog(@"2ar=%@,cou=%ld,2c=%d",_dataArray,_dataArray.count,self.pageNumbs);
    //    DEBUGLog(@"Debug:allid>%@,%ld",_dataArray.lastObject,[_dataArray.lastObject connectId]);
    
}

#pragma mark  -- 分解开的数据
- (void)resolveArrays{
    //取到申购日放到数组中；
    NSMutableArray *subscribeDayAry = [NSMutableArray array];
    
    for (int i=0; i<_dataArray.count; i++) {
        NSDictionary *subDic = _dataArray[i];
        [subscribeDayAry addObject: subDic[@"SUB_BGN_DT_ON"]];
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
    
    
    NSMutableArray *allArray = [NSMutableArray array];
    for (int i=0; i<_subscribeArray.count; i++) {
        //分段数组
        NSMutableArray *disjunctionArray = [NSMutableArray array];
        //分区标题日期
        NSDate *sectionTitle = _subscribeArray[i];
        
        for (int j=0; j<_subscribeArray.count; j++) {
//            NSDate *tempObj = _subscribeArray[j];
            NSDate *tempObj = ((BDNewStockModel *)_subscribeArray[j]).SUB_BGN_DT_ON;
            //如果总数据数组里的某个时间 与 分区头部 某个时间相同
            //就把本组数据加入到一个新的 分段数组中
            if ([tempObj isEqual:sectionTitle] ) { //isEqualToDate:sectionTitle
                [disjunctionArray addObject:_subscribeArray[j]];
                [disjunctionArray addObject:(BDNewStockModel *)_subscribeArray[j]];
            }
        }
        //最后放入一个新的大数组中
        [allArray addObject:disjunctionArray];
    }
    _allArrays = allArray;
}

#pragma mark  -- 如果没有数据，界面显示“近期无IPO新股申购”
- (void)creatOtherView{
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake((self.view.frame.size.width-150)/2, 15, 150, 25);
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *headView = (UITableViewHeaderFooterView *)view;
    for (int i=0; i<_subscribeArray.count; i++) {
        section = i;
        headView.textLabel.text = _subscribeArray[i];//标题
    }
    view.tintColor = [UIColor darkGrayColor];
    headView.textLabel.font = [UIFont systemFontOfSize:15];
    headView.textLabel.textColor = [UIColor blueColor];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _allArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [_allArrays[section] count];
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    
    NSMutableArray *sectionAry = _allArrays[indexPath.section];//取到当前分区对应的数组
//    BDNewStockModel *nsModel = sectionAry[indexPath.row];//取得当前行对应的数据
//    //一一对应
//    cell.textLabel.text = nsModel.SECU_SHT;
    
    NSMutableArray *testAry = sectionAry[indexPath.row];
    cell.textLabel.text = testAry[0][@"SECU_SHT"];

    
    return cell;
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
