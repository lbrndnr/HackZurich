//
//  WebService.m
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "WebService.h"

#define BASE_URL @"http://hz14.the-admins.ch"

//Register and Login
#define REGISTER_USER @"auth/local/register"
#define LOGIN_USER @"auth/local/login"

//Feed operations
#define CREATE_FEED @"api/feeds/"
#define UPDATE_FEED @"api/feeds/"
#define DELETE_FEED @"api/feeds/"


//Feedstream operations
#define GET_FEEDS @"api/feeds/"
#define UPDATE_FEEDSTREAM @"api/feeds/"


//SYnc

#define SYNC @"api/sync/syncs"

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

     string = [NSString stringWithFormat:@"%@/%@",BASE_URL,parameter];

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
//            completion(nil, @"No device Token");
//        }
//        self.currentUser = nil;
//            return false;
//        
//    }

    if (completion) {
        __block User *user = nil;
        
        NSDictionary* payload = @{@"email": username, @"password": password, @"device_token":self.deviceToken == nil?@"":self.deviceToken};
        NSData *body = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
        
        NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"POST" withOperation:REGISTER_USER andData:body];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                user = [[User alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
                self.currentUser = user;
                completion(user, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            });
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
//    
//    if(self.deviceToken == nil) {
//        if(completion) {
//            completion(nil, @"No Device Token");
//        }
//        self.currentUser = nil;
//        return false;
//    }
    
    __block User *user = nil;
    
    NSDictionary* payload = @{@"email": username, @"password": password, @"device_token" : self.deviceToken==nil?@"":self.deviceToken};
    NSData *body = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"POST" withOperation:LOGIN_USER andData:body];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            user = [[User alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
            self.currentUser = user;
            if (completion) {
                completion(user, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        });
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
-(BOOL)createNewFeed:(Feed *) injFeed withCompletion:(void(^)(Feed *)) completion {
    if(self.currentUser == nil) {
        if(completion) {
            completion(nil);
        }
        return false;
        
    }
    if(completion) {
        __block Feed *feed = injFeed;
        
    
    NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"POST" withOperation:CREATE_FEED andDataAsString:[feed toJSONString]];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            feed = [[Feed alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
            
            NSMutableArray* feeds = self.feeds.mutableCopy ?: [NSMutableArray new];
            if (feed) {
                [feeds addObject:feed];
            }
            else {
                NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            self.feeds = (NSArray<Feed>*)feeds;
            
            if (completion) {
                completion(feed);
            }
        });
    }];
    
    [task resume];
    }
    
    return YES;


}
/*
 Update Feed
 PRE:
 Id: Feed id which should be updated
 Name: A name for the feed
 Description: Describe the way your feed is acting on the input
 Uri: Pointer to a online ressource of an ICS file
 [OPTIONAL] Filter: The Filter rules including the included InputFeeds (DO NOT SET FOR INPUTFEED!!!)
 
 */
-(BOOL)updateFeed:(Feed *)injFeed withCompletion:(void(^)(Feed *)) completion {
    if(self.currentUser == nil) {
        if(completion) {
            completion(nil);
        }
        return false;
        
    }
    if(completion) {
        __block Feed *feed = injFeed;
        
        
        
        NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"PUT" withPutParams:feed._id withOperation:UPDATE_FEED andDataAsString:[feed toJSONString]];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           dispatch_async(dispatch_get_main_queue(), ^{
               feed = [[Feed alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
               completion(feed);
           });
        }];
        
        [task resume];
    }
    
    return YES;
    
}

/*
 Delete Feed
 PRE:
 Fedd which should be deleted
 
 POST
 Boolean if success
 */

-(BOOL)deleteFeed:(Feed *)feed withCompletion:(void(^)(BOOL)) completion {
    if(self.currentUser == nil) return NO;
    
    NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"DELETE" withOperation:DELETE_FEED andDataAsString:feed._id];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(((NSHTTPURLResponse *)response).statusCode == 204) {
            [self getListFeedWithCompletion:nil];
        }
        else {
            
        }
    }];
    
    [task resume];
    return  YES;
}


///*
// Update Feedstream
// PRE: Updated list of all feeds used (wanted) by the user
// 
// POST:
// Boolean indicating status
// 
// */
//-(BOOL)updateFeedstreamWithCompletion:(void (^)(Feedstream *)) completion {
//    if(self.currentUser == nil) {
//        if(completion) {
//            completion(nil);
//        }
//        return NO;
//        
//    }
//    Feedstream *stream = [Feedstream new];
//    stream.feeds = self.feeds;
//    NSMutableURLRequest *request = [self createMutableRequestWithMethod:UPDATE_FEEDSTREAM withOperation:@"POST" andDataAsString:[stream toJSONString]];
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            Feedstream *feeds = [[Feedstream alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:nil];
//            self.feeds = feeds.feeds;
//            if(completion) {
//                completion(feeds);
//            }
//        });
//    }];
//    
//    [task resume];
//    
//    return  YES;
//    
//}




/*
 Get feeds
 
  NOTE: Getting the auth token from the currentUser property
 
 PRE:
 Auth-Token: The auth token representing the current session
 
 POST:
 NSArray<Feed> (List of feeds, mixed input and outputfeeds)
 */

-(BOOL)getListFeedWithCompletion:(void(^)(NSArray<Feed> *)) completion {
    if(self.currentUser == nil) return NO;
    
    NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"GET" withOperation:GET_FEEDS andDataAsString:@""];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            JSONModelError *error = nil;
            Feedstream *feeds = [[Feedstream alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&error];
            self.feeds = feeds.feeds;
            
            if (completion) {
                completion(feeds.feeds);
            }
            else {
                 NSLog(@"%@ --- %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
            }
        });
    }];
    [task resume];
    
    
    return YES;
}

/*
 Create a MutableURLRequest with given method and given data as string
 PRE
 Method: representing the REST-Method for the HTTP Request
 Data: Either a string concated to the url (GET) or a Json-Object (POST)
 
 POST
 The created MutableURLREquest
 
 */

-(NSMutableURLRequest *) createMutableRequestWithMethod:(NSString *)method withOperation:(NSString *)operation andDataAsString:(NSString *)data {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getRequestWithOperation:operation]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:method];
    
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.currentUser.access_token ] forHTTPHeaderField:@"Authorization"];
    
    if([method compare:@"POST"] == NSOrderedSame) {
        //We have a post request, so our string is a json string representing the object -> add to body
        
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    else if ([method compare:@"GET"] == NSOrderedSame) {
        //We have a get request, so concat the string to the url
        NSURL *url = [request URL];
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", data]];
        [request setURL:url];
        
    }
    
    else if ([method compare:@"DELETE"] == NSOrderedSame) {
        NSURL *url = [request URL];
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", data]];
        [request setURL:url];
    }
    
    
    return request;
}

-(NSMutableURLRequest *) createMutableRequestWithMethod:(NSString *)method withPutParams:(NSString *) putparams withOperation:(NSString *)operation andDataAsString:(NSString *)data {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getRequestWithOperation:operation]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:method];
    
        [request addValue:[NSString stringWithFormat:@"Bearer %@", self.currentUser.access_token ] forHTTPHeaderField:@"Authorization"];
    
    if([method compare:@"PUT"] == NSOrderedSame) {
        //We have a PUT request, so our string is a json string representing the object -> add to body; we also set the PUT parameter
        
        NSURL *url = [request URL];
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@", putparams]];
        [request setURL:url];
        
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    else  {
       //Request has to be PUT
        return nil;
        
    }
    
    
    return request;
}




-(NSMutableURLRequest *) createMutableRequestWithMethod:(NSString *)method withOperation:(NSString *)operation andData:(NSData *)data {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getRequestWithOperation:operation]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:method];
    
        [request addValue:[NSString stringWithFormat:@"Bearer %@", self.currentUser.access_token ] forHTTPHeaderField:@"Authorization"];
    
    if([method compare:@"POST"] == NSOrderedSame) {
        //We have a post request, so our string is a json string representing the object -> add to body
        
        [request setHTTPBody:data];
    }
    
    else if ([method compare:@"GET"] == NSOrderedSame) {
        //Cannot generate a NSMUtableURLREquest with an NSData object
        return nil;
    }
    
    
    return request;
}

-(void)giveMeASync {
    NSMutableURLRequest *request = [self createMutableRequestWithMethod:@"GET" withOperation:SYNC andDataAsString:@""];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request];
    
    [task resume];
}


@end
