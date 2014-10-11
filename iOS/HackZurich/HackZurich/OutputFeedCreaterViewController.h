//
//  OutputFeedCreaterViewController.h
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface OutputFeedCreaterViewController : UITableViewController

@property (nonatomic, readonly) Feed* feed;

-(instancetype)initWithFeed:(Feed*)feed;

@end
