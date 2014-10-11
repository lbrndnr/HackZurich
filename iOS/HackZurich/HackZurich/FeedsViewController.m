//
//  SecondViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "FeedsViewController.h"
#import "WebService.h"
#import "OutputFeedCreaterViewController.h"

@interface FeedsViewController ()

-(void)presentOutputFeedCreatorViewController:(id)sender;
-(void)dismissOutputFeedCreatorViewController:(id)sender;

@end
@implementation FeedsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Feeds", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentOutputFeedCreatorViewController:)];
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [WebService sharedService].feeds.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed* feed = [WebService sharedService].feeds[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    cell.textLabel.text = feed.name;
    
    return cell;
}

-(void)presentOutputFeedCreatorViewController:(id)sender {
    OutputFeedCreaterViewController* controller = [OutputFeedCreaterViewController new];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissOutputFeedCreatorViewController:)];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)dismissOutputFeedCreatorViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
