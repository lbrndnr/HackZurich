//
//  CalendarTableViewCell.h
//  HackZurich
//
//  Created by Laurin Brandner on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XbICalendar.h"

@interface CalendarTableViewCell : UITableViewCell

@property (nonatomic, strong) XbICVEvent* event;

//+(CGFloat)heightForEvent:(XbICVEvent*)event constraint:(CGSize)constraint;

@end
