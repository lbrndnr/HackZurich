//
//  OutputFeed.h
//  HackZurich
//
//  Created by Patrick Amrein on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel/JSONModelLib.h"
#import "Filter.h"

@interface Feed : JSONModel

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) NSArray<Filter, Optional>* filters;

@property (nonatomic) BOOL isVisible;


@end

@protocol Feed

@end