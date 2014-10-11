//
//  FirstViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarTableViewCell.h"
#import "FeedsVisiblityViewController.h"
#import "XbICalendar.h"
#import "WebService.h"

NSString* const CalendarViewControllerSelectedCalendarUIDsKey = @"CalendarViewControllerSelectedCalendarUIDs";

@interface CalendarViewController ()

@property (nonatomic, strong) NSArray* selectedFeeds;
@property (nonatomic, strong) NSArray* sectionDates;
@property (nonatomic, strong) NSArray* events;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, weak) FeedsVisiblityViewController* visiblityViewController;

-(void)reloadTableView;

-(void)presentFeedVisibilityViewController:(id)sender;
-(void)dismissFeedVisibilityViewController:(id)sender;

-(void)downloadCalenderDataWithURL:(NSURL *)URL withCompletion:(void (^)(NSData*))completion;

@end
@implementation CalendarViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Calendar", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Feed", nil) style:UIBarButtonItemStylePlain target:self action:@selector(presentFeedVisibilityViewController:)];
    
    Class cellClass = [CalendarTableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    self.tableView.rowHeight = 64.0f;
    
    NSArray* availableFeeds = [WebService sharedService].feeds;
    NSMutableArray* selectedFeeds = [NSMutableArray new];
    NSArray* selectedFeedUIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:CalendarViewControllerSelectedCalendarUIDsKey];
    for (Feed* feed in availableFeeds) {
        if ([selectedFeedUIDs containsObject:feed._id]) {
            [selectedFeeds addObject:feed];
        }
    }
    self.selectedFeeds = selectedFeeds;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)self.events[section]).count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dateFormatter stringFromDate:self.sectionDates[section]];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XbICVEvent* event = ((NSArray*)self.events[indexPath.section])[indexPath.row];
    CalendarTableViewCell* cell = (CalendarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CalendarTableViewCell class]) forIndexPath:indexPath];
    
    cell.event = event;
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)reloadTableView {
    __block NSInteger counter = self.selectedFeeds.count;
    NSMutableArray* calendars = [NSMutableArray new];
    for (Feed* feed in self.selectedFeeds) {
        NSURL* URL = [NSURL URLWithString:feed.uri];
        [self downloadCalenderDataWithURL:URL withCompletion:^(NSData* data) {
            [calendars addObject:data];
            counter--;
            
            if (counter <= 0) {
                NSMutableArray* newSectionDates = [NSMutableArray new];
                NSMutableArray* newEvents = [NSMutableArray new];
                
                NSMutableArray* allEvents = [NSMutableArray new];
                for (NSData* calendarData in calendars) {
                    NSString* content = [[NSString alloc] initWithData:calendarData encoding:NSUTF8StringEncoding];
                    XbICVCalendar * vCalendar =  [XbICVCalendar vCalendarFromString:content];
                    [allEvents addObjectsFromArray:[vCalendar componentsOfKind:ICAL_VEVENT_COMPONENT]];
                }
                [allEvents sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateStart)) ascending:YES]]];
                
                NSInteger lastDay = 0;
                NSInteger lastMonth = 0;
                NSInteger lastYear = 0;
                
                for (XbICVEvent* event in allEvents) {
                    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:event.dateStart];
                    NSInteger day = components.day;
                    NSInteger month = components.month;
                    NSInteger year = components.year;
                    
                    if (lastDay != day || lastMonth != month || lastYear != year) {
                        lastDay = day;
                        lastMonth = month;
                        lastYear = year;
                        
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
            }
        }];
    }
}

-(void)presentFeedVisibilityViewController:(id)sender {
    FeedsVisiblityViewController* controller = [FeedsVisiblityViewController new];
    controller.selectedFeeds = self.selectedFeeds;
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissFeedVisibilityViewController:)];
    self.visiblityViewController = controller;
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    UIPopoverController* popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)dismissFeedVisibilityViewController:(id)sender {
    self.selectedFeeds = self.visiblityViewController.selectedFeeds;
    //[self reloadTableView];
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
