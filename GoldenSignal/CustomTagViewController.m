//
//  CustomTagViewController.m
//  CBNAPP
//
//  Created by Frank on 14-10-15.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "CustomTagViewController.h"
#import "CustomTagsViewModel.h"

@interface CustomTagViewController ()

@end

@implementation CustomTagViewController
{
    CustomTagsViewModel *_model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _model = [[CustomTagsViewModel alloc] init];
    
    self.topTagsTableView.delegate = self;
    self.topTagsTableView.dataSource = self;
    
    self.subTagsTableView.delegate = self;
    self.subTagsTableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.topTagsTableView) {
        return _model.topTags.count;
    }
    else if (tableView == self.subTagsTableView) {
        return _model.subTags.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.topTagsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopTagCell" forIndexPath:indexPath];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:29/255.0 green:34/255.0 blue:40/255.0 alpha:1];
        
        BDNewsTag *tag = (BDNewsTag *)_model.topTags[indexPath.row];
        cell.textLabel.text = tag.name;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        
        // 设置选中的cell
        if (tag == _model.selectedTag) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        return cell;
    }
    else if (tableView == self.subTagsTableView) {
        SubTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubTagCell" forIndexPath:indexPath];
        cell.tag = _model.subTags[indexPath.row];
        return cell;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.topTagsTableView) {
        BDNewsTag *label = _model.topTags[indexPath.row];
        _model.selectedTag = label;
        [self.subTagsTableView reloadData];
    }
}

@end


#pragma mark - LabelTableViewCell

@implementation SubTagTableViewCell

@synthesize tag;

- (void)awakeFromNib {
    [self.checkMarkBtn setImage:[UIImage imageNamed:@"checkMark_0"] forState:UIControlStateNormal];
    [self.checkMarkBtn setImage:[UIImage imageNamed:@"checkMark_1"] forState:UIControlStateSelected];
    self.textLabel.font = [UIFont boldSystemFontOfSize:12];
}

- (void)setTag:(BDNewsTag *)value {
    tag = value;
    self.textLabel.text = tag.name;
    self.isCustom = [[BDCustomTagCollection sharedInstance] IsCustomized:tag];
}

- (void)setIsCustom:(BOOL)value {
    self.checkMarkBtn.selected = value;
}

- (BOOL)getIsCustom {
    return self.checkMarkBtn.selected;
}

- (IBAction)singleTapCheckMarkBtn:(UIButton *)sender {
    self.isCustom = !self.isCustom;
    CustomTagsViewModel *model = [CustomTagsViewModel new];
    if (self.isCustom) {
        [model addTag:self.tag];
    }
    else {
        [model removeTagById:self.tag.innerId];
    }
}

@end
