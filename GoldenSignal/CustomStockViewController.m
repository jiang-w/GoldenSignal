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
#import "StockViewController.h"

@interface CustomStockViewController ()

@end

@implementation CustomStockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(customStockChanged:) name:CUSTOM_STOCK_CHANGED_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customStockChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [BDStockPool sharedInstance].codes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *bdCode = [[BDStockPool sharedInstance].codes objectAtIndex:indexPath.row];
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
    [self performSegueWithIdentifier:@"StockViewSegue" sender:cell.code];
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
        StockViewController *stockVC = (StockViewController *)segue.destinationViewController;
        stockVC.defaultCode = code;
    }
}

@end
