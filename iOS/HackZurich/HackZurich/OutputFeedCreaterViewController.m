//
//  OutputFeedCreaterViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "OutputFeedCreaterViewController.h"
#import "InputTableViewCell.h"
#import "Filter.h"
#import "WebService.h"

#define NAME_SECTION 0
#define DESC_SECTION 1
#define FEEDS_SECTION 2
#define FILTER_SECTION 3

@interface OutputFeedCreaterViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL editing;
@property (nonatomic, strong) Feed* feed;
@property (nonatomic, strong) NSMutableArray* availableInputFeeds;

@property (nonatomic, weak) UIAlertAction* inputSensitiveAction;
@property (nonatomic, strong) NSArray* requiredAlertViewTextFields;

@property (nonatomic, strong) UIBarButtonItem* doneItem;

-(void)textFieldDidChangeValue:(UITextField*)sender;
-(void)alertTextFieldDidChangeValue:(UITextField*)sender;

-(void)reloadDoneItemAvailabilty;
-(void)done:(id)sender;

@end
@implementation OutputFeedCreaterViewController

-(instancetype)init {
    return [self initWithFeed:nil];
}

-(instancetype)initWithFeed:(Feed *)feed {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.feed = feed;
        if (!self.feed) {
            self.feed = [Feed new];
            self.feed.filter = [Filter new];
        }
        else {
            self.editing = YES;
        }
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"New Feed", nil);
    
    self.doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.doneItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.doneItem;
    
    NSMutableArray* feeds = [NSMutableArray arrayWithArray:[WebService sharedService].feeds];
    NSUInteger duplicateIndex = NSNotFound;
    for (Feed* feed in feeds) {
        if ([feed._id isEqualToString:self.feed._id]) {
            duplicateIndex = [feeds indexOfObject:feed];
            break;
        }
    }
    if (duplicateIndex != NSNotFound) {
        [feeds removeObjectAtIndex:duplicateIndex];
    }
    self.availableInputFeeds = feeds;
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    
    cellClass = [InputTableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == FEEDS_SECTION) {
        return self.availableInputFeeds.count+1;
    }
    else if (section == FILTER_SECTION) {
        return self.feed.filter.rules.count+1;
    }
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == FEEDS_SECTION) {
        return NSLocalizedString(@"Input Feeds", nil);
    }
    else if (section == FILTER_SECTION) {
        return NSLocalizedString(@"Filters", nil);
    }
    
    return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section <= DESC_SECTION) {
        InputTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.textLabel.text = (indexPath.section == NAME_SECTION) ? NSLocalizedString(@"Name:", nil) : NSLocalizedString(@"Description:", nil);
        cell.textField.placeholder = (indexPath.section == NAME_SECTION) ? NSLocalizedString(@"Feed", nil) : NSLocalizedString(@"Some more details", nil);
        cell.textField.delegate = self;
        cell.textField.tag = indexPath.section;
        [cell.textField addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == FEEDS_SECTION) {
        if (indexPath.row < self.availableInputFeeds.count) {
            Feed* feed = self.availableInputFeeds[indexPath.row];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", feed.name, feed.url];
            if ([self.feed.filter.inputs containsObject:feed]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Add", nil);
            cell.textLabel.textColor = tableView.tintColor;
        }
    }
    else {
        if (indexPath.row < self.feed.filter.rules.count) {
            Rule* rule = self.feed.filter.rules[indexPath.row];
            cell.textLabel.text = rule.title;
        }
        else {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Add", nil);
            cell.textLabel.textColor = tableView.tintColor;
        }
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == FEEDS_SECTION) || (indexPath.section == FILTER_SECTION && indexPath.row == self.feed.filter.rules.count);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == FEEDS_SECTION) {
        if (indexPath.row < self.availableInputFeeds.count) {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            NSMutableArray* newInputFeeds = self.feed.filter.inputs.mutableCopy ?: [NSMutableArray new];
            if ([self.feed.filter.inputs containsObject:self.availableInputFeeds[indexPath.row]]) {
                [newInputFeeds removeObjectAtIndex:indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                [newInputFeeds addObject:self.availableInputFeeds[indexPath.row]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            self.feed.filter.inputs = (NSArray<Feed> *)newInputFeeds;
            [self reloadDoneItemAvailabilty];
        }
        else {
            UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add new input feed", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            NSMutableArray* requiredTextFields = [NSMutableArray new];
            
            [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"Name", nil);
                [textField addTarget:self action:@selector(alertTextFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
                [requiredTextFields addObject:textField];
            }];
            [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"Description", nil);
            }];
            [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"URL", nil);
                textField.keyboardType = UIKeyboardTypeURL;
                [textField addTarget:self action:@selector(alertTextFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
                [requiredTextFields addObject:textField];
            }];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            UIAlertAction* addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField* nameTextField = controller.textFields.firstObject;
                UITextField* descTextField = controller.textFields[1];
                UITextField* URLTextField = controller.textFields[2];
                
                Feed* feed = [Feed new];
                feed.name = nameTextField.text;
                feed.desc = descTextField.text;
                feed.url = URLTextField.text;
                [self.availableInputFeeds addObject:feed];
                
                NSMutableArray* newInputFeeds = self.feed.filter.inputs.mutableCopy ?: [NSMutableArray new];
                [newInputFeeds addObject:feed];
                self.feed.filter.inputs = (NSArray<Feed> *)newInputFeeds;
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.availableInputFeeds.count-1 inSection:FEEDS_SECTION]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                
                [self reloadDoneItemAvailabilty];
            }];
            addAction.enabled = NO;
            [controller addAction:addAction];
            self.inputSensitiveAction = addAction;
            
            self.requiredAlertViewTextFields = requiredTextFields;
            
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    else if (indexPath.section == FILTER_SECTION) {
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add new Filter", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.delegate = self;
            textField.placeholder = NSLocalizedString(@"#tag or substring", nil);
            [textField addTarget:self action:@selector(alertTextFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
            self.requiredAlertViewTextFields = @[textField];
        }];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        UIAlertAction* addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField* textField = controller.textFields.firstObject;
            NSString* text = textField.text;
            BOOL tag = [text hasPrefix:@"#"];
            Rule* newRule = [Rule new];
            newRule.type = (tag) ? RuleTypeTag : RuleTypeSubstring;
            newRule.text = (tag) ? [text substringFromIndex:1] : text;
            
            NSMutableArray* newRules = self.feed.filter.rules.mutableCopy ?: [NSMutableArray new];
            [newRules addObject:newRule];
            self.feed.filter.rules = (NSArray<Rule>*)newRules;
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.feed.filter.rules.count-1 inSection:FILTER_SECTION]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }];
        addAction.enabled = NO;
        [controller addAction:addAction];
        self.inputSensitiveAction = addAction;
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == FILTER_SECTION && indexPath.row != self.feed.filter.rules.count);
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Unsubscribe", nil);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray* newRules = self.feed.filter.rules.mutableCopy;
        [newRules removeObjectAtIndex:indexPath.row];
        self.feed.filter.rules = (NSArray<Rule>*)newRules;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

-(void)reloadDoneItemAvailabilty {
    self.doneItem.enabled = (self.feed.name.length > 0) && (self.feed.filter.inputs.count > 0);
}

-(void)done:(id)sender {
    if (self.editing) {
        [[WebService sharedService] updateFeed:self.feed withCompletion:^(Feed* feed) {
            if (feed) {
                [[WebService sharedService] getListFeedWithCompletion:nil];
            }
            else {
                UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Feed could not be created.", nil) preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:controller animated:YES completion:nil];
            }
        }];
    }
    else {
        [[WebService sharedService] createNewFeed:self.feed withCompletion:^(Feed* feed) {
            if (feed) {
                [[WebService sharedService] getListFeedWithCompletion:nil];
            }
            else {
                UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Feed could not be created.", nil) preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:controller animated:YES completion:nil];
            }
        }];
    }
}

-(void)textFieldDidChangeValue:(UITextField *)sender {
    if (sender.tag == NAME_SECTION) {
        self.feed.name = sender.text;
    }
    else {
        self.feed.desc = sender.text;
    }
    [self reloadDoneItemAvailabilty];
}

-(void)alertTextFieldDidChangeValue:(UITextField*)sender {
    BOOL full = YES;
    for (UITextField* textField in self.requiredAlertViewTextFields) {
        if (!textField.hasText) {
            full = NO;
            break;
        }
    }
    self.inputSensitiveAction.enabled = full;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == NAME_SECTION) {
        InputTableViewCell* cell = (InputTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DESC_SECTION]];
        [cell.textField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
