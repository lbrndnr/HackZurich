//
//  Rule.h
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "JSONModel.h"

@interface Rule : JSONModel
@property (nonatomic) int type;
@property (strong, nonatomic) NSString *text;
@property (nonatomic) BOOL in_body;
@property (nonatomic) BOOL in_subject;
@end

@protocol Rule

@end