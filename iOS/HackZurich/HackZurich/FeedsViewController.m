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
-(void)outputFeedCreatorDidFinishEditing:(NSNotification*)notification;

@end
@implementation FeedsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputFeedCreatorDidFinishEditing:) name:OutputFeedCreaterViewControllerDidFinishEditingNotification object:nil];
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed* feed = [WebService sharedService].feeds[indexPath.row];
    OutputFeedCreaterViewController* controller = [[OutputFeedCreaterViewController alloc] initWithFeed:feed];
    [self.navigationController pushViewController:controller animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Feed* feed = [WebService sharedService].feeds[indexPath.row];
        
        NSMutableArray* newFeedes = [WebService sharedService].feeds.mutableCopy;
        [newFeedes removeObjectAtIndex:indexPath.row];
        [WebService sharedService].feeds = (NSArray<Feed>*)newFeedes;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        [[WebService sharedService] deleteFeed:feed withCompletion:nil];
    }
}

-(void)presentOutputFeedCreatorViewController:(id)sender {
    OutputFeedCreaterViewController* controller = [OutputFeedCreaterViewController new];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissOutputFeedCreatorViewController:)];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)dismissOutputFeedCreatorViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToViewController:self animated:YES];
}

-(void)outputFeedCreatorDidFinishEditing:(NSNotification *)notification {
    [self dismissOutputFeedCreatorViewController:nil];
}

@end
