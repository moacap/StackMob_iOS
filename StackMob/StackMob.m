//
//  StackMob.m
//  MeetingRoom
//
//  Created by Josh Stephenson on 7/10/11.
//  Copyright 2011 StackMob. All rights reserved.
//

#import "StackMob.h"
#import "StackMobRequest.h"
#import "StackMobAdditions.h"
#import "StackMobClientData.h"
#import "StackMobCustomRequest.h"

@interface StackMob (Private)
- (void)queueRequest:(StackMobRequest *)request andCallback:(StackMobCallback)callback;
- (void)run;
- (void)next;
@end

@implementation StackMob

@synthesize requests;
@synthesize callbacks;
@synthesize session;

static StackMob *_sharedManager = nil;

+ (StackMob *)stackmob {
    if (_sharedManager == nil) {
        _sharedManager = [[super allocWithZone:NULL] init];
        NSString *filename = [[NSBundle mainBundle] pathForResource:@"StackMob" ofType:@"plist"];
        NSDictionary *appInfo = [[NSDictionary dictionaryWithContentsOfFile:filename] objectForKey:@"production"];

        _sharedManager.session = [[StackMobSession sessionForApplication:[appInfo objectForKey:@"publicKey"]
                                                                  secret:[appInfo objectForKey:@"privateKey"]
                                                                 appName:[appInfo objectForKey:@"appName"]
                                                               subDomain:[appInfo objectForKey:@"appSubdomain"]
                                                                  domain:[appInfo objectForKey:@"domain"]
                                                          userObjectName:[appInfo objectForKey:@"userObjectName"]
                                                        apiVersionNumber:[appInfo objectForKey:@"apiVersion"]] retain];
        _sharedManager.requests = [NSMutableArray array];
        _sharedManager.callbacks = [NSMutableArray array];

        if(!filename || !appInfo){
            [NSException raise:@"StackMob.plist format error" format:@"Please ensure proper formatting.  Toplevel should have 'production' or 'development' key."];
        }
    }
    return _sharedManager;
}

#pragma mark - Session Methods

- (void)startSession{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"startsession" withHttpVerb:POST];
    [self queueRequest:request andCallback:nil];
}

- (void)endSession{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"endsession" withHttpVerb:POST];
    [self queueRequest:request andCallback:nil];
}

# pragma mark - User object Methods
- (void)loginwithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    [self post:[NSString stringWithFormat:@"%@/login", session.userObjectName]
     withArguments:arguments
    andCallback:callback];
}

- (void)getUserInfowithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    [self get:session.userObjectName
   withArguments:arguments
  andCallback:callback];
}

# pragma mark - Facebook methods
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

# pragma mark - CRUD methods

- (void)get:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:GET]; 
    [self queueRequest:request andCallback:callback];
}

- (void)get:(NSString *)path withCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:NULL
                                                    withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
}

- (void)customGet:(NSString *)path withCallback:(StackMobCallback)callback
{
    StackMobCustomRequest *request = [StackMobCustomRequest requestForMethod:path
                                                   withArguments:NULL
                                                    withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
}

- (void)customGet:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobCustomRequest *request = [StackMobCustomRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
}

- (void)post:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
}

- (void)customPost:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobCustomRequest *request = [StackMobCustomRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
}

- (void)post:(NSString *)path forUser:(NSString *)user withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    NSDictionary *modifiedArguments = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [modifiedArguments setValue:user forKey:session.userObjectName];
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/%@", session.userObjectName, path]
                                                   withArguments:modifiedArguments
                                                    withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
}

- (void)put:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:PUT];
    [self queueRequest:request andCallback:callback];
}

- (void)destroy:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:DELETE];
    [self queueRequest:request andCallback:callback];
}

# pragma mark - Private methods
- (void)queueRequest:(StackMobRequest *)request andCallback:(StackMobCallback)callback
{
    request.delegate = self;
    
    [self.requests addObject:request];
    if(callback)
        [self.callbacks addObject:Block_copy(callback)];
    else
        [self.callbacks addObject:[NSNull null]];
    
    [callback release];
    
    [self run];
}

- (void)run
{
    if(!_running){
        if([self.requests isEmpty]) return;
        currentRequest = [self.requests objectAtIndex:0];
        [currentRequest sendRequest];
        _running = YES;
    }
}

- (void)next
{
    _running = NO;
    currentRequest = nil;
    [self run];
}

#pragma mark - StackMobRequestDelegate

- (void)requestCompleted:(StackMobRequest*)request {
//    [request retain];  // TODO: wtf
    if([self.requests containsObject:request]){
        NSInteger index = [self.requests indexOfObject:request];
        StackMobCallback callback = [self.callbacks objectAtIndex:index];
        SMLog(@"status %d", request.httpResponse.statusCode);
        if((NSNull *)callback != [NSNull null]){
            callback(request.httpResponse.statusCode < 300 && request.httpResponse.statusCode > 0, [request result]);
            Block_release(callback);
        }else{
            SMLog(@"no callback found");
        }
        [self.callbacks removeObjectAtIndex:index];
        SMLog(@"requests %d, request %d", [self.requests retainCount], [request retainCount]);
        [self.requests removeObject:request];
        [self next];
    }
}

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
