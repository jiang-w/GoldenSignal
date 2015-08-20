//
//  RankingListViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/7/9.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "RankingListViewController.h"
#import "RankingListCell.h"
#import "BDSectService.h"

@interface RankingListViewController ()

@end

@implementation RankingListViewController
{
    NSMutableArray *_secuCodeArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 36;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGB(30, 30, 30);
    self.tableView.allowsSelection = NO;
}

- (void)loadDataWithSectId:(NSUInteger)sectId andNumber:(NSUInteger)number orderByDesc:(BOOL)desc {
    if  (_secuCodeArray == nil) {
        _secuCodeArray = [NSMutableArray array];
    }
    
    BDSectService *service = [[BDSectService alloc] init];
    [_secuCodeArray removeAllObjects];
    NSArray *arr = [service getSecuCodesBySectId:sectId sortByIndicateName:@"ChangeRange" ascending:!desc];
    if (arr.count >= number) {
        [_secuCodeArray addObjectsFromArray:[arr subarrayWithRange:NSMakeRange(0, number)]];
    }
    else {
        [_secuCodeArray addObjectsFromArray:arr];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _secuCodeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingListCell *cell = (RankingListCell *)[tableView dequeueReusableCellWithIdentifier:@"RankingListCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RankingListCell" owner:self options:nil];
        for (id obj in nib) {
            if ([obj isKindOfClass:[RankingListCell class]]) {
                cell = (RankingListCell *)obj;
                break;
            }
        }
    }
    cell.code = [_secuCodeArray objectAtIndex:indexPath.row];
    return cell;
}

@end
