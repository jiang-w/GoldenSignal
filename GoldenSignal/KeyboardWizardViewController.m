//
//  KeyboardWizardViewController.m
//  CBNAPP
//
//  Created by Frank on 14/11/18.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "KeyboardWizardViewController.h"

@interface KeyboardWizardViewController ()

@end

@implementation KeyboardWizardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_secuSearchBar becomeFirstResponder];
}

- (IBAction)prevButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BDSecuCode *secuCode = searchResults[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", secuCode.trdCode, secuCode.name];
        if ([[BDStockPool sharedInstance] containStockWithCode:secuCode.bdCode]) {
            UILabel *label = [[UILabel alloc] init];
            label.text = @"已添加";
            label.textColor = [UIColor grayColor];
            label.font = [UIFont systemFontOfSize:12];
            [label sizeToFit];
            cell.accessoryView = label;
        }
        else {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
            btn.backgroundColor = [UIColor clearColor];
            btn.tintColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(btnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btn;
        }
    }
    return cell;
}

- (void)btnClicked:(id)sender event:(id)event {
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil) {
        BDStockPool *pool = [BDStockPool sharedInstance];
        BDSecuCode *secuCode = [searchResults objectAtIndex:indexPath.row];
        [pool addStockWithCode:secuCode.bdCode];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"已添加";
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:12];
        [label sizeToFit];
        cell.accessoryView = label;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BDSecuCode *secuCode;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        secuCode = searchResults[indexPath.row];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:KEYBOARD_WIZARD_NOTIFICATION object:nil userInfo:@{@"BD_CODE": secuCode.bdCode}];
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchResults = [[NSMutableArray alloc]init];
    [searchResults addObjectsFromArray:[[BDKeyboardWizard sharedInstance] fuzzyQueryWithText:self.secuSearchBar.text]];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    UITableView *tableView = controller.searchResultsTableView;
    tableView.backgroundColor = [UIColor colorWithRed:29/255.0 green:34/255.0 blue:40/255.0 alpha:1];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

// 按下键盘search按钮触发
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchResults.count > 0) {
        BDSecuCode *secuCode = [searchResults firstObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEYBOARD_WIZARD_NOTIFICATION object:nil userInfo:@{@"BD_CODE": secuCode.bdCode}];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
