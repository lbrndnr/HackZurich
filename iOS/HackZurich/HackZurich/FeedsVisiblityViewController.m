//
//  FeedsVisiblityViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "FeedsVisiblityViewController.h"
#import "WebService.h"

@interface FeedsVisiblityViewController ()

-(void)reloadSelection;

@end
@implementation FeedsVisiblityViewController

-(void)setSelectedFeeds:(NSArray *)selectedFeeds {
    if (![_selectedFeeds isEqualToArray:selectedFeeds]) {
        _selectedFeeds = selectedFeeds;
        
        [self reloadSelection];
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Visible Feeds", nil);
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadSelection];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Feed* feed = [WebService sharedService].feeds[indexPath.row];
    
    NSMutableArray* newSelectedFeeds = self.selectedFeeds.mutableCopy ?: [NSMutableArray new];
    if ([newSelectedFeeds containsObject:feed]) {
        [newSelectedFeeds removeObject:feed];
    }
    else {
        [newSelectedFeeds addObject:feed];
    }
    self.selectedFeeds = newSelectedFeeds;
}

-(void)reloadSelection {
    for (NSUInteger r = 0; r < [self tableView:self.tableView numberOfRowsInSection:0]; r++) {
        Feed* feed = [WebService sharedService].feeds[r];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:0]];
        cell.accessoryType = ([self.selectedFeeds containsObject:feed]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

@end
