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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity = 0;
    dispatch_async(loadDataQueue, ^{
        NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadSortedSecuCodes) userInfo:nil repeats:YES];
        [time fire];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSortedSecuCodes {
    BDSectService *service = [[BDSectService alloc] init];
//    _sectCodeArray = [service getSecuCodesBySectId:_sectId SortByIndicateName:nil];
    _sectCodeArray = [service getSecuCodesBySectId:_sectId andCodes:nil sortByIndicateName:nil ascending:NO];
    if (_sectCodeArray.count > 0) {
        // 返回主线程刷新视图
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
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
