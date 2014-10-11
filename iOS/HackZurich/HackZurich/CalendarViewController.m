//
//  FirstViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "CalendarViewController.h"
#import "FeedsVisiblityViewController.h"
#import "XbICalendar.h"

@interface CalendarViewController ()

@property (nonatomic, strong) NSArray* sectionDates;
@property (nonatomic, strong) NSArray* events;
@property (nonatomic, weak) FeedsVisiblityViewController* visiblityViewController;

-(void)presentFeedVisibilityViewController:(id)sender;
-(void)dismissFeedVisibilityViewController:(id)sender;

-(void)downloadCalenderDataWithURL:(NSURL *)URL withCompletion:(void (^)(NSData*))completion;

@end
@implementation CalendarViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Calendar", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dini Muetter", nil) style:UIBarButtonItemStylePlain target:self action:@selector(presentFeedVisibilityViewController:)];
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSURL* URL = [NSURL URLWithString:@"https://www.google.com/calendar/ical/uuvar5p1a250iuu4ntg1mebm5k%40group.calendar.google.com/public/basic.ics"];
    [self downloadCalenderDataWithURL:URL withCompletion:^(NSData* data) {
        NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XbICVCalendar * vCalendar =  [XbICVCalendar vCalendarFromString:content];
        
        NSMutableArray* newSectionDates = [NSMutableArray new];
        NSMutableArray* newEvents = [NSMutableArray new];
        
        NSArray* allEvents = [vCalendar componentsOfKind:ICAL_VEVENT_COMPONENT];
        allEvents = [allEvents sortedArrayUsingSelector:@selector(dateStart)];
        
        NSInteger lastDay = 0;
        NSInteger lastMonth = 0;
        NSInteger lastYear = 0;
        
        for (XbICVEvent* event in allEvents) {
            NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:event.dateStart];
            NSInteger day = [components day];
            NSInteger month = [components month];
            NSInteger year = [components year];
            
            if (lastDay != day || lastMonth != month || lastYear != year) {
                [newSectionDates addObject:event.dateStart];
                [newEvents addObject:[NSMutableArray arrayWithObject:event]];
            }
            else {
                [((NSMutableArray*)newEvents.lastObject) addObject:event];
            }
        }
        
        self.sectionDates = newSectionDates;
        self.events = newEvents;
        [self.tableView reloadData];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)self.events[section]).count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XbICVEvent* event = ((NSArray*)self.events[indexPath.section])[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    cell.textLabel.text = event.description;
    
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

-(void)downloadCalenderDataWithURL:(NSURL *)URL withCompletion:(void (^)(NSData*))completion {
    if (completion) {
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data);
            });
        }];
        [task resume];
    }
}

@end
