//
//  CalendarTableViewCell.m
//  HackZurich
//
//  Created by Laurin Brandner on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "CalendarTableViewCell.h"

@implementation CalendarTableViewCell

-(void)setEvent:(XbICVEvent *)event {
    if (![_event isEqual:event]) {
        _event = event;
        
        self.textLabel.text = [event.description stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];
    }
}

@end
