//
//  Feedstream.h
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "JSONModel.h"
#import "Feed.h"


@interface Feedstream : JSONModel


@property (strong, nonatomic) NSArray<Feed> *feeds;
@end
