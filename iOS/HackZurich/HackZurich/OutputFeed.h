//
//  OutputFeed.h
//  HackZurich
//
//  Created by Patrick Amrein on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputFeed : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableArray *inputFeeds; //Of type InputFeed
@property (strong, nonatomic) NSMutableArray *filters; //Of type Filter
@property (nonatomic) BOOL isVisible;



-(void)createOnServer;
-(void)updateOnServer;


@end
