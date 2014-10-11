//
//  User.h
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *auth;
@end
