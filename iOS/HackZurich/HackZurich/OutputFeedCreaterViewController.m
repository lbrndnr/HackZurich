//
//  OutputFeedCreaterViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "OutputFeedCreaterViewController.h"

@interface OutputFeedCreaterViewController ()

@property (nonatomic, strong) NSMutableArray* inputFeeds;
@property (nonatomic, strong) NSMutableArray* filters;

@end
@implementation OutputFeedCreaterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputFeeds = [NSMutableArray arrayWithObjects:@"haha", @"yolo", nil];
    self.filters = [NSMutableArray arrayWithObjects:@"#tag", @"damn", nil];
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.inputFeeds.count;
    }
    
    return self.filters.count+1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Input Feeds", nil);
    }
    
    return NSLocalizedString(@"Filters", nil);
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.inputFeeds[0];
    }
    else {
        if (indexPath.row < self.filters.count) {
            cell.textLabel.text = self.filters[indexPath.row];
        }
        else {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Add", nil);
        }
    }
    
    return cell;
}

@end
