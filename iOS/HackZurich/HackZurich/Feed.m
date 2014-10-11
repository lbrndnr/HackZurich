//
//  OutputFeed.m
//  HackZurich
//
//  Created by Patrick Amrein on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "Feed.h"

@implementation Feed

-(BOOL)isEqual:(Feed*)object {
    if ([object isKindOfClass:[Feed class]]) {
        return [self._id isEqualToString:object._id];
    }
    
    return NO;
}

-(NSUInteger)hash {
    return self._id.hash;
}

@end
