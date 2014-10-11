//
//  WebService.m
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "WebService.h"

#define BASE_URL @"http://hz14.the-admins.ch"
#define REGISTER_USER @"auth/local/register"
#define LOGIN_USER @"auth/local/login"
#define CREATE_FEED @""

@implementation WebService

+(WebService *) sharedService {
    static WebService * sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [WebService new];
    });
    
    return sharedService;
}


-(NSString *) getRequestWithOperation:(NSString *) parameter {
    NSString *string = nil;
    if(self.currentUser == nil) {
     string = [NSString stringWithFormat:@"%@/%@",BASE_URL,parameter];
    }
    else {
        string = [NSString stringWithFormat:@"%@/%@?auth=%@",BASE_URL,parameter, self.currentUser.access_token];
    }
    return  string;
}

/*
 Register Function
 PRE:
 Username: the username (!!!always an E-Mailaddress !!!) used for the Webservice
 Password: Password in cleartext (Connection via https)
 PushToken (generated by the UIApplication remote thing): used for PushMessages
 
 POST:
 true if succeeded false otherwise
 the self.currentUser was not set if return value is false
 IMPORTANT: Send the auth-token in the User-INstance for every further request
 
 */

-(BOOL)registerUser:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(User *, NSString*))completion {
//    if (self.deviceToken == nil) {
//        if (completion) {
//            completion(nil);
//        }
//        self.currentUser = nil;
//            return false;
//        
//    }

    if (completion) {
        __block User *user = nil;
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getRequestWithOperation:REGISTER_USER]]];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"POST"];
        
        NSData *body = [[NSString stringWithFormat:@"email=%@&password=%@&device_token=%@", username, password, self.deviceToken]dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPBody:body];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            user = [[User alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
            completion(user, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            self.currentUser = user;
        }];
        
        [task resume];
    }
    
    return  YES;
}

/*
 Login Function
 
 PRE:
 Username: the username (!!!always an E-Mailaddress !!!) used for the Webservice
 Password: Password in cleartext (Connection via https)
 PushToken (generated by the UIApplication remote thing): used for PushMessages
 
 POST:
 true if succeeded false otherwise
  the self.currentUser was not set if return value is false
 IMPORTANT: Send the auth-token in the User-INstance for every further request
 */
-(BOOL) login:(NSString *)username withPassword:(NSString *)password  withCompletion:(void (^)(User *, NSString*))completion {
    
//    if(self.deviceToken == nil) {
//        if(completion) {
//            completion(nil);
//        }
//        self.currentUser = nil;
//        return false;
//    }
    
    __block User *user = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getRequestWithOperation:LOGIN_USER]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSData *body = [[NSString stringWithFormat:@"email=%@&password=%@&device_token=%@", username, password, self.deviceToken]dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [request setHTTPBody:body];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        user = [[User alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
        if (completion) {
            completion(user, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
        self.currentUser = user;
    }];
    [task resume];

    return YES;
}


/*
 Create New Input Feed
 IMPORTANT NO FILTER FOR INPUTFEED
 PRE:
 Name: A name for the feed
 Description: Describe the way your feed is acting on the input
 Uri: Pointer to a online ressource of an ICS file
 [OPTIONAL] Filter: The Filter rules including the included InputFeeds (DO NOT SET FOR INPUTFEED!!!)
 
 POST:
true if succeeded false otherwise
 */
-(BOOL)createNewFeedWithName:(NSString *) name withDescription:(NSString *)desc withFilters:(NSArray<Filter> *)filters withCompletion:(void(^)(Feed *)) completion {
    if(self.currentUser == nil) {
        if(completion) {
            completion(nil);
        }
        return false;
        
    }
    if(completion) {
        __block Feed *feed = nil;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getRequestWithOperation:CREATE_FEED]]];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            feed = [[Feed alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
            completion(feed);
        }];
        
        [task resume];
    }
    
    return YES;
}



@end
