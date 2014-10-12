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
#import "CalendarDetailViewController.h"
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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:131.0f/255.0f blue:67.0f/255.0f alpha:1.0f];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self  action:@selector(reloadTableView) forControlEvents:UIControlEventValueChanged];
    
    [[WebService sharedService] getListFeedWithCompletion:^(NSArray<Feed> *feeds) {
        NSMutableArray* selectedFeeds = [NSMutableArray new];
        NSArray* selectedFeedUIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:CalendarViewControllerSelectedCalendarUIDsKey];
        for (Feed* feed in feeds) {
            if ([selectedFeedUIDs containsObject:feed._id]) {
                [selectedFeeds addObject:feed];
            }
        }
        self.selectedFeeds = selectedFeeds;
        [self reloadTableView];
    }];
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XbICVEvent* event = ((NSArray*)self.events[indexPath.section])[indexPath.row];
    CalendarDetailViewController* controller = [[CalendarDetailViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)reloadTableView {
    if (self.selectedFeeds.count == 0) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.refreshControl beginRefreshing];
    
    __block NSInteger counter = self.selectedFeeds.count;
    NSMutableArray* calendars = [NSMutableArray new];
    for (Feed* feed in self.selectedFeeds) {
        NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://hz14.the-admins.ch/ics/%@",feed.filter._id ]];
        [self downloadCalenderDataWithURL:URL withCompletion:^(NSData* data) {
            [calendars addObject:data];
            counter--;
            
            if (counter <= 0) {
                NSMutableArray* newSectionDates = [NSMutableArray new];
                NSMutableArray* newEvents = [NSMutableArray new];
                NSMutableSet* eventIDs = [NSMutableSet set];
                
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
                    if ([eventIDs containsObject:event.UID]) {
                        continue;
                    }
                    [eventIDs addObject:event.UID];
                    
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
                
                [self.refreshControl endRefreshing];
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
    
    NSMutableArray* IDs = [NSMutableArray new];
    for (Feed* feed in self.selectedFeeds) {
        [IDs addObject:feed._id];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:IDs forKey:CalendarViewControllerSelectedCalendarUIDsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self reloadTableView];
    }];
}

-(void)downloadCalenderDataWithURL:(NSURL *)URL withCompletion:(void (^)(NSData*))completion {
    if (completion) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request addValue:[NSString stringWithFormat:@"Bearer %@", [WebService sharedService].currentUser.access_token ] forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data);
            });
        }];
        [task resume];
    }
}

@end
