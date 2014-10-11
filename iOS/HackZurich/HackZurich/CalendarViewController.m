//
//  FirstViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "CalendarViewController.h"
#import "FeedsVisiblityViewController.h"

@interface CalendarViewController ()

@property (nonatomic, strong) NSArray* events;
@property (nonatomic, weak) FeedsVisiblityViewController* visiblityViewController;

-(void)presentFeedVisibilityViewController:(id)sender;
-(void)dismissFeedVisibilityViewController:(id)sender;

@end
@implementation CalendarViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Calendar", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dini Muetter", nil) style:UIBarButtonItemStylePlain target:self action:@selector(presentFeedVisibilityViewController:)];
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)self.events[section]).count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    
    return cell;
}

-(void)presentFeedVisibilityViewController:(id)sender {
    FeedsVisiblityViewController* controller = [FeedsVisiblityViewController new];
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissFeedVisibilityViewController:)];
    self.visiblityViewController = controller;
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    UIPopoverController* popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)dismissFeedVisibilityViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
