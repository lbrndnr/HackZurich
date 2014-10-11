//
//  WebService.m
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "WebService.h"

@implementation WebService

+(WebService *) sharedService {
    static WebService * sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [WebService new];
    });
    
    return sharedService;
}
@end
