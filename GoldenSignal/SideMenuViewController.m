//
//  LeftTableViewController.m
//  CBNAPP
//
//  Created by Frank on 14-9-1.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

@synthesize revealController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BDChannel *newsColumn = [BDChannel createWithName:@"新闻" imageName:@"news.png" className:@"NewsListViewController"];
    BDChannel *picColumn = [BDChannel createWithName:@"行情" imageName:@"pic.png" className:@"PicViewController"];
    BDChannel *commentColumn = [BDChannel createWithName:@"自选股" imageName:@"comment.png" className:@"CommentViewController"];
    _columnArray = @[newsColumn,picColumn,commentColumn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _columnArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell"];
    BDChannel *column = _columnArray[indexPath.row];
    cell.textLabel.text = column.name;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:column.imageName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITabBarController *tabBar = (UITabBarController *)self.revealController.contentViewController;
    BDChannel *channel = _columnArray[indexPath.row];
    if ([channel.name isEqualToString:@"新闻"]) {
        tabBar.selectedIndex = 0;
    }
    [self.revealController toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

@end
