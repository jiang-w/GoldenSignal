//
//  CustomStockViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/1/20.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "CustomStockViewController.h"
#import "QuoteViewCell.h"
#import "IdxQuoteViewCell.h"
#import "StockDetailViewController.h"
#import "IdxDetailViewController.h"
#import "BDSectService.h"
#import "MBProgressHUD/MBProgressHUD.h"


@interface CustomStockViewController ()

@end

@implementation CustomStockViewController
{
    NSArray *_secuCodes;
    BOOL _asc;
    dispatch_queue_t loadDataQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _asc = NO;
    [self loadSortedSecuCodes];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(customStockChanged:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customStockChanged:(NSNotification *)notification {
    NSString *op = notification.userInfo[@"op"];
    if ([op isEqualToString:@"add"]) {
        [self loadSortedSecuCodes];
    }
}

- (void)loadSortedSecuCodes {
    NSNumber *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userIdentity"];
    _secuCodes = [NSArray arrayWithArray:[BDStockPool sharedInstance].codes];
    if (_secuCodes.count > 0) {
        BDSectService *service = [[BDSectService alloc] init];
        _secuCodes = [service getSecuCodesBySectId:[userId longValue] andCodes:_secuCodes sortByIndicateName:nil ascending:_asc];
        // 返回主线程刷新视图
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _secuCodes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *bdCode = [_secuCodes objectAtIndex:indexPath.row];
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:bdCode];
    switch (secu.typ) {
        case stock: {
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
            break;
        }
        case idx: {
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
            break;
        }
        default:
            break;
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor blackColor];
    }
    else {
        cell.backgroundColor = RGB(30, 30, 30, 1);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QuoteViewCell *cell = (QuoteViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:cell.code];
    if (secu.typ == idx) {
        IdxDetailViewController *idxVC = [[IdxDetailViewController alloc] initWithIdxCode:secu.bdCode];
        idxVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:idxVC animated:NO];
    }
    else {
        [self performSegueWithIdentifier:@"StockViewSegue" sender:secu.bdCode];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        QuoteViewCell *cell = (QuoteViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [[BDStockPool sharedInstance] removeStockWithCode:cell.code];
        _secuCodes = [NSArray arrayWithArray:[BDStockPool sharedInstance].codes];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

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

#pragma mark navigation

// 设置跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StockViewSegue"]) {
        NSString *code = (NSString *)sender;
        StockDetailViewController *stockVC = (StockDetailViewController *)segue.destinationViewController;
        stockVC.defaultCode = code;
    }
}

@end
