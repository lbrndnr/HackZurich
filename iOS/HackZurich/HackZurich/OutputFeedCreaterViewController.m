//
//  OutputFeedCreaterViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "OutputFeedCreaterViewController.h"
#import "Feed.h"

@interface OutputFeedCreaterViewController ()

@property (nonatomic, strong) NSMutableArray* availableInputFeeds;
@property (nonatomic, strong) NSMutableIndexSet* selectedInputFeedIndices;
@property (nonatomic, strong) NSMutableArray* filters;

@end
@implementation OutputFeedCreaterViewController

-(instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    Feed* feed = [Feed new];
    feed.name = @"YOLO";
    feed.url = @"http://BAZINGA.com";
    
    self.availableInputFeeds = [NSMutableArray arrayWithObject:feed];
    self.selectedInputFeedIndices = [NSMutableIndexSet new];
    self.filters = [NSMutableArray arrayWithObjects:@"#tag", @"damn", nil];
    
    Class cellClass = [UITableViewCell class];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.availableInputFeeds.count+1;
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
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.availableInputFeeds.count) {
            Feed* feed = self.availableInputFeeds[indexPath.row];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", feed.name, feed.url];
            if ([self.selectedInputFeedIndices containsIndex:indexPath.row]) {
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
        if (indexPath.row < self.filters.count) {
            cell.textLabel.text = self.filters[indexPath.row];
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
    return (indexPath.section == 0) || (indexPath.section == 1 && indexPath.row == self.filters.count);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.availableInputFeeds.count) {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([self.selectedInputFeedIndices containsIndex:indexPath.row]) {
                [self.selectedInputFeedIndices removeIndex:indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                [self.selectedInputFeedIndices addIndex:indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else {
            UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add new input feed", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"Name", nil);
            }];
            [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"Description", nil);
            }];
            [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"URL", nil);
                textField.keyboardType = UIKeyboardTypeURL;
            }];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
                
                UITextField* nameTextField = controller.textFields.firstObject;
                UITextField* descTextField = controller.textFields[1];
                UITextField* URLTextField = controller.textFields[2];
                
                Feed* feed = [Feed new];
                feed.name = nameTextField.text;
                feed.desc = descTextField.text;
                feed.url = URLTextField.text;
                [self.availableInputFeeds addObject:feed];
                [self.selectedInputFeedIndices addIndex:[self.availableInputFeeds indexOfObject:feed]];
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.availableInputFeeds.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }]];
            
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    else {
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add new Filter", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"#tag or substring", nil);
        }];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            UITextField* textField = controller.textFields.firstObject;
            [self.filters addObject:textField.text];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.filters.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 1 && indexPath.row != self.filters.count);
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Unsubscribe", nil);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.filters removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}


@end
