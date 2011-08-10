//
//  StackMob.m
//  MeetingRoom
//
//  Created by Josh Stephenson on 7/10/11.
//  Copyright 2011 StackMob. All rights reserved.
//

#import "StackMob.h"
#import "StackMobRequest.h"
#import "StackMobClientData.h"

@interface StackMob (Private)
- (void)queueRequest:(StackMobRequest *)request andCallback:(StackMobCallback)callback;
- (void)run;
@end

@implementation StackMob

@synthesize requests;
@synthesize callbacks;
@synthesize session;

static StackMob *_sharedManager = nil;
NSString * const kAPIKey = @"83454cea-33de-4527-8176-69b8c9b4d183";
NSString * const kAPISecret = @"4403e237-c7a2-49a1-8c7b-df441b16e1c9";
NSString * const kSubDomain = @"fithsaring";
NSString * const kAppName = @"meetingroom";
NSString * const kDomain = @"stackmob.com";
NSString * const kUserObjectName = @"user";

#define API_VERSION [NSNumber numberWithInt:1]

+ (StackMob *)stackmob {
    if (_sharedManager == nil) {
        _sharedManager = [[super allocWithZone:NULL] init];
        _sharedManager.session = [[StackMobSession sessionForApplication:kAPIKey
                                                    secret:kAPISecret
                                                   appName:kAppName
                                                 subDomain:kSubDomain
                                                    domain:kDomain
                                            userObjectName:kUserObjectName
                                          apiVersionNumber:API_VERSION] retain];
        _sharedManager.requests = [NSMutableArray array];
        _sharedManager.callbacks = [NSMutableArray array];
        
    }
    return _sharedManager;
}

- (void)startSession{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"startsession" withHttpVerb:POST];
    [self queueRequest:request andCallback:nil];
}

- (void)loginWithFacebookToken:(NSString *)facebookToken andCallback:(StackMobCallback)callback{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"facebookLogin" withArguments:args withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
}

- (void)registerWithFacebookToken:(NSString *)facebookToken username:(NSString *)username andCallback:(StackMobCallback)callback{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", username, @"username", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"createUserWithFacebook" withArguments:args withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
}

- (void)get:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:params
                                                    withHttpVerb:GET]; 
    [self queueRequest:request andCallback:callback];
}

- (void)get:(NSString *)path withCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:NULL
                                                    withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
}

- (void)post:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:params
                                                    withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
}

- (void)post:(NSString *)path forUser:(NSString *)user withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback{
    NSDictionary *modifiedParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [modifiedParams setValue:user forKey:kUserObjectName];
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/%@", kUserObjectName, path]
                                                   withArguments:params
                                                    withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
}

- (void)put:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:params
                                                    withHttpVerb:PUT];
    [self queueRequest:request andCallback:callback];
}

- (void)destroy:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:params
                                                    withHttpVerb:DELETE];
    [self queueRequest:request andCallback:callback];
}

- (void)queueRequest:(StackMobRequest *)request andCallback:(StackMobCallback)callback{
    request.delegate = self;
    
    [self.requests addObject:request];
    if(callback)
        [self.callbacks addObject:Block_copy(callback)];
    else
        [self.callbacks addObject:[NSNull null]];
    
    [callback release];
    
    [self run];
}

- (void)run{
    if(!_running){
        if([self.requests count] == 0) return;
        NSLog(@"running...");
        StackMobRequest *request = [self.requests objectAtIndex:0];
        [request sendRequest];
        _running = YES;
    }
}

- (void)next{
    _running = [self.requests count] > 0;
    if(_running) [self run];
}

#pragma mark -
#pragma mark StackMobRequestDelegate

- (void)requestCompleted:(StackMobRequest*)request {
//    [request retain];  // TODO: wtf
    if([self.requests containsObject:request]){
        NSInteger index = [self.requests indexOfObject:request];
        StackMobCallback callback = [self.callbacks objectAtIndex:index];
        StackMobLog(@"status %d", request.httpResponse.statusCode);
        if((NSNull *)callback != [NSNull null]){
            callback(request.httpResponse.statusCode < 300 && request.httpResponse.statusCode > 0, [request result]);
            Block_release(callback);
        }else{
            StackMobLog(@"no callback found");
        }
        [self.callbacks removeObjectAtIndex:index];
        StackMobLog(@"requests %d, request %d", [self.requests retainCount], [request retainCount]);
        [self.requests removeObject:request];
        [self next];
    }
}

# pragma mark -
# pragma mark - Singleton Conformity
static StackMob *sharedSession = nil;

+ (StackMob *)sharedManager
{
    if (sharedSession == nil) {
        sharedSession = [[super allocWithZone:NULL] init];
    }
    return sharedSession;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)release
{
    // do nothing
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (id)autorelease
{
    return self;
}
@end
