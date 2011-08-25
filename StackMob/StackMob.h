//
//  StackMob.h
//  MeetingRoom
//
//  Created by Josh Stephenson on 7/10/11.
//  Copyright 2011 StackMob. All rights reserved.
//

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

+ (StackMob *)stackmob;

/* 
 * Make sure to call this in appDidFinishLaunching
 *
 */
- (void)startSession;

/*
 * Make sure to call 
 *
 */
- (void)endSession;

/*
 * Logs a user in using the user object name set when initializing StackMobSession
 * @params A dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (void)loginWithParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;
/*
 * Gets a user object using the user object name set when initializing 
 * StackMobSession
 * @params A dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (void)getUserInfoWithParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

/*
 * Authenticates a user in your StackMob app using their Facebook Token.  
 * Assumes the user is already registered
 * @facebookToken the user's facebook access token
 */
- (void)loginWithFacebookToken:(NSString *)facebookToken andCallback:(StackMobCallback)callback;

/* 
 * Registerrs a new user in your StackMob app using their facebook token
 * and a user selected username (you can default it to their Facebook username
 * assuming they have set one)
 * @facebookToken the user's facebook access token
 */
- (void)registerWithFacebookToken:(NSString *)facebookToken username:(NSString *)username andCallback:(StackMobCallback)callback;

/* 
 * Get the object with name "path" and params dictionary
 * @params a dictionary whose keys correspond to object field names on Stackmob Object Model
 */
- (void)get:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

/* 
 * Get the object with name "path" with no params
 * @path the name of the object to get in your stackmob app
 * Will return all items of object type
 */
- (void)get:(NSString *)path withCallback:(StackMobCallback)callback;

/*
 * TODO: Are these even necessary?
 */
- (void)customGet:(NSString *)path withCallback:(StackMobCallback)callback;
- (void)customGet:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

/* 
 * POST the params to the given object model with name of "path"
 * @path the name of the object to create in your stackmob app
 * @params a dictionary whose keys correspond to field names of the object in your Stackmob app
 */
- (void)post:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

/* 
 * TODO: is this even necessary?
 */
- (void)post:(NSString *)path forUser:(NSString *)user withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

- (void)customPost:(NSString *)path withCallback:(StackMobCallback)callback;

/*
 * PUT the params to the given object path
 * @path the name of the object in your Stackmob app
 * @params a Dictionary of attributes whose  keys correspond to field names of the object in your Stackmob app
 */
- (void)put:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

/* 
 * DELETE the object at the given path
 * @path the name of the object in your stackmob app
 * @params a Dictonary with one key that corresponds to your object's primary key
 *   the value of which is the item to delete
 */
- (void)destroy:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;


@end
