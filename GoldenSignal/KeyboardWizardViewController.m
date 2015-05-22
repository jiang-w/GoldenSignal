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
        cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:34/255.0 blue:40/255.0 alpha:1];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BDSecuCode *secuCode = searchResults[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", secuCode.trdCode, secuCode.name];
    }
    return cell;
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
//    searchResults = [[NSMutableArray alloc]init];
//    if (self.secuSearchBar.text.length > 0) {
//        for (int i=0; i < dataArray.count; i++) {
//            BDSecuCode *secuCode = dataArray[i];
//            NSRange range1 = [secuCode.trdCode rangeOfString:self.secuSearchBar.text options:NSCaseInsensitiveSearch];
//            NSRange range2 = [secuCode.py rangeOfString:self.secuSearchBar.text options:NSCaseInsensitiveSearch];
//            NSRange range3 = [secuCode.name rangeOfString:self.secuSearchBar.text options:NSCaseInsensitiveSearch];
//            if (range1.length > 0 || range2.length || range3.length) {
//                [searchResults addObject:dataArray[i]];
//            }
//        }
//    }
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
