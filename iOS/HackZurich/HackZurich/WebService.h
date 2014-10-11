//
//  WebService.h
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Feed.h"

@interface WebService : NSObject

+(WebService *) sharedService;

@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSArray<Feed> *feeds;

//WebService Implementations

/*
 Register Function
PRE: 
        Username: the username (!!!always an E-Mailaddress !!!) used for the Webservice
        Password: Password in cleartext (Connection via https)
        PushToken (generated by the UIApplication remote thing): used for PushMessages
 
 POST: null or a User Objective representing the user which is logged in
 IMPORTANT: Send the auth-token in the User-INstance for every further request
 
*/

-(BOOL)registerUser:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(User*, NSString*))completion;

/*
 Login Function

 PRE:
        Username: the username (!!!always an E-Mailaddress !!!) used for the Webservice
        Password: Password in cleartext (Connection via https)
        PushToken (generated by the UIApplication remote thing): used for PushMessages
 
 POST: null or a User Objective representing the user which is logged in
        IMPORTANT: Send the auth-token in the User-INstance for every further request
 */
-(BOOL)login:(NSString *)username withPassword:(NSString*)password  withCompletion:(void(^)(User *, NSString*)) completion;



/*
 Create New Input Feed
 IMPORTANT NO FILTER FOR INPUTFEED
 PRE:
        Name: A name for the feed
        Description: Describe the way your feed is acting on the input
        Uri: Pointer to a online ressource of an ICS file
        [OPTIONAL] Filter: The Filter rules including the included InputFeeds (DO NOT SET FOR INPUTFEED!!!)
 
 POST:
 Null or generated Feed Object
 */
-(BOOL)createNewFeedWithName:(NSString *) name withDescription:(NSString *)desc withFilters:(Filter *)filter withCompletion:(void(^)(Feed *)) completion;


/*
 Get feeds
 PRE:
        Auth-Token: The auth token representing the current session
 
 POST:
        NSArray<Feed> (List of feeds, mixed input and outputfeeds)
*/
-(BOOL)getListFeedWithAuthToken:(NSString *)token withCompletion:(void(^)(NSArray<Feed> *)) completion;


/*
 Get the request string (URL)
 PRE:
        parameter: the request operation

 POST:
        the url prepared
 
 */
-(NSString *) getRequestWithOperation:(NSString *) parameter;

/*
 Create a MutableURLRequest with given method and given data as string
 PRE
        Method: representing the REST-Method for the HTTP Request
        Data: Either a string concated to the url (GET) or a Json-Object (POST)
 
 POST
        The created MutableURLREquest
 
 */

-(NSMutableURLRequest *) createMutableRequestWithMethod:(NSString *)method withOperation:(NSString *)operation  andDataAsString:(NSString *)data;

//same as above but with NSData,a allready serialized json object

-(NSMutableURLRequest *) createMutableRequestWithMethod:(NSString *)method withOperation:(NSString *)operation  andData:(NSData *)data;

@end
