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
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSString *uri;


@property (strong, nonatomic) Filter<Optional>* filter;



@end

@protocol Feed

@end