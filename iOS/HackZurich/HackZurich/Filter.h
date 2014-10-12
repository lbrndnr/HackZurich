//
//  Filter.h
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "JSONModel.h"
#import "Rule.h"

@class Feed;
@protocol Feed;




@interface Filter : JSONModel
@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *output;
@property (strong, nonatomic) NSArray<Rule, Optional> *rules;
@property (strong, nonatomic) NSArray *inputs;
@end

@protocol Filter

@end

