// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#import "StackMobSession.h"
#import "StackMobRequest.h"

typedef void (^StackMobCallback)(BOOL success, id result);

@interface StackMob : NSObject <SMRequestDelegate>{
    NSMutableArray *callbacks;
    NSMutableArray *requests;
    StackMobSession *session;
    StackMobRequest *currentRequest;
    BOOL _running;
}

@property (nonatomic, retain) StackMobSession *session;
@property (nonatomic, retain) NSMutableArray *callbacks;
@property (nonatomic, retain) NSMutableArray *requests;


/*
 * Manually configure your session.  Subsequent requests for the StackMob
 * singleton can use [StackMob stackmob]
 */
+ (StackMob *)setApplication:(NSString *)apiKey secret:(NSString *)apiSecret appName:(NSString *)appName subDomain:(NSString *)subDomain userObjectName:(NSString *)userObjectName apiVersionNumber:(NSNumber *)apiVersion;

/*
 * Returns the pre-configured or auto-configured singleton
 * all instance methods are called on the singleton
 * If this method is called before setApplication:secret:appName:subDomain:userObjectName:apiVersonNumber
 * it will load the app config info from StackMob.plist in the main Bundle
 */
+ (StackMob *)stackmob;

/* 
 * Initializes a user session
 * Make sure to call this in appDidFinishLaunching
 */
- (StackMobRequest *)startSession;

/*
 * Ends a user session
 * Make sure to call this in applicationWillEnterBackground and applicationWillTerminate
 */
- (StackMobRequest *)endSession;

/*
 * Registers a new userusing the user object name set when initializing StackMobSession
 * @param arguments A dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (StackMobRequest *)registerWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/*
 * Logs a user in using the user object name set when initializing StackMobSession
 * @param arguments A dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (StackMobRequest *)loginWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/*
 * Logs the current user out
 */
- (StackMobRequest *)logoutWithCallback:(StackMobCallback)callback;

/*
 * Gets a user object using the user object name set when initializing 
 * StackMobSession
 * @param arguments A dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (StackMobRequest *)getUserInfowithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/*
 * Authenticates a user in your StackMob app using their Facebook Token.  
 * Assumes the user is already registered
 * @param facebookToken the user's facebook access token
 */
- (StackMobRequest *)loginWithFacebookToken:(NSString *)facebookToken andCallback:(StackMobCallback)callback;

/* 
 * Registerrs a new user in your StackMob app using their facebook token
 * and a user selected username (you can default it to their Facebook username
 * assuming they have set one)
 * @param facebookToken the user's facebook access token
 */
- (StackMobRequest *)registerWithFacebookToken:(NSString *)facebookToken username:(NSString *)username andCallback:(StackMobCallback)callback;

/* 
 * Register a User for PUSH notifications
 * @param arguments a Dictionary 
 */
- (StackMobRequest *)registerUserForPushWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/* 
 * Get the object with name "path" and arguments dictionary
 * @param arguments a dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (StackMobRequest *)get:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/* 
 * Get the object with name "path" with no arguments.  This will return all items of object type
 * @param path the name of the object to get in your stackmob app
 */
- (StackMobRequest *)get:(NSString *)path withCallback:(StackMobCallback)callback;

/*
 * TODO: Are these even necessary?
 */
- (StackMobRequest *)customGet:(NSString *)path withCallback:(StackMobCallback)callback;
- (StackMobRequest *)customGet:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/* 
 * POST the arguments to the given object model with name of "path"
 * @param path the name of the object in your stackmob app to be created
 * @param arguments a dictionary whose keys correspond to field names of the object in your Stackmob app
 */
- (StackMobRequest *)post:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/*
 * POST the arguments for a user
 * @param path the name of the object in your stackmob app to be created
 * @param arguments a dictionary whose keys correspond to field names of the object in your Stackmob app
 */
- (StackMobRequest *)post:(NSString *)path forUser:(NSString *)user withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/*
 * POST the arguments for a custom action on heroku
 * @param path the name of the object in your stackmob app to be created (without 'heroku/proxy')
 * @param arguments a dictionary whose keys correspond to field names of the object in your Stackmob app
 */
- (StackMobRequest *)customPost:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/*
 * PUT the arguments to the given object path
 * @path the name of the object in your Stackmob app
 * @param arguments a Dictionary of attributes whose  keys correspond to field names of the object in your Stackmob app
 */
- (StackMobRequest *)put:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

/* 
 * DELETE the object at the given path
 * @path the name of the object in your stackmob app
 * @param arguments a Dictonary with one key that corresponds to your object's primary key
 *   the value of which is the item to delete
 */
- (StackMobRequest *)destroy:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback;

@end
