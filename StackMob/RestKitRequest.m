//
//  RestkitRequest.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMob.h"
#import "RestKitRequest.h"
#import "StackMobRequest.h"
#import "StackMobSession.h"
#import "RestKitObjectLoaderDelegate.h"

@interface RestKitRequest (Private)
- (RKRequestMethod) requestMethodFromString:(NSString *)verb;
- (RestKitObjectLoaderDelegate *) loaderDelegate:(id<SMRequestDelegate>)requestDelegate;
- (NSString *)baseUrlWithSession:(StackMobSession *)sess;
@end

@implementation RestKitRequest
@synthesize objectManager = _objectManager;
@synthesize authClient = _authClient;
@synthesize loader;

#pragma mark - RKOAuthClientDelegate

- (void)OAuthClient:(RKOAuthClient *)client didAcquireAccessToken:(NSString *)token
{
    
}

- (void)OAuthClient:(RKOAuthClient *)client didFailWithInvalidGrantError:(NSError *)error
{
    
}

+ (id)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb
{
    return nil;
}

+ (id)userRequestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb
{
    return nil;
}

/*
 * Create a request for an iOS PUSH notification
 @param arguments a dictionary of arguments including :alert, :badge and :sound
 */
+ (id)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb
{
    //[self respondsToSelector:@selector(_cmd)];
    return nil;
}

# pragma mark - Initialization

+ (id)request	
{
    RestKitRequest *request = [[[RestKitRequest alloc] init] autorelease];
    return request;
}

+ (id)userRequest
{
    StackMobRequest *request = [self request];
    request.userBased = YES;
    return request;
}

+ (id)requestForMethod:(NSString*)method
{
	return [self requestForMethod:method withHttpVerb:GET];
}	

+ (id)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [self requestForMethod:method withObject:nil withHttpVerb:httpVerb];
}

+ (id)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [self userRequestForMethod:method withObject:nil withHttpVerb:httpVerb];    
}

+ (id)requestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
    RestKitRequest *request = [RestKitRequest request];
    request.method = method;
    [request setObject:object];
    request.httpMethod = [self stringFromHttpVerb:httpVerb];
    return request;
}

+ (id)userRequestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
    RestKitRequest *request = [self requestForMethod:method withObject:object withHttpVerb:httpVerb];
    request.userBased = YES;
    return request;
}

+ (id)requestForMethod:(NSString *)method withData:(NSData *)data{
    /*StackMobRequest *request = [self request];
     request.method = method;
     request.httpMethod = [self stringFromHttpVerb:POST];
     request.body = data;
     return request;
     */
    return nil;
}

- (NSString *)baseUrlWithSession:(StackMobSession *)sess
{
    NSString *protocol = (self.isSecure) ? @"https" : @"http";
    NSString *url = [NSString stringWithFormat:@"%@://%@.%@", protocol, sess.subDomain, sess.domain];
    return url;
}

- (id)init
{
	self = [super init];
    if(self){
        
        NSString *baseUrl = [self baseUrlWithSession:session];
        _objectManager = [[RKObjectManager objectManagerWithBaseURL:baseUrl] retain];
        _objectManager.client.baseURL = [NSString stringWithFormat:@"%@",baseUrl];
        _objectManager.client.OAuth1ConsumerKey =session.apiKey;
        _objectManager.client.OAuth1ConsumerSecret = session.apiSecret;
        //_objectManager.client.OAuth1AccessToken = @"YOUR ACCESS TOKEN";
        //_objectManager.client.OAuth1AccessTokenSecret = @"YOUR ACCESS TOKEN SECRET";
        _objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth1;
    }
    
    
	return self;
}

- (NSInteger) getStatusCode
{
    return [[loader response] statusCode];
}

#pragma mark -

- (RKRequestMethod) requestMethodFromString:(NSString *)verb
{
    if([verb isEqualToString:@"POST"])
    {
        return RKRequestMethodPOST;
    }
    else if([verb isEqualToString:@"GET"])
    {
        return RKRequestMethodGET;
    }
    else if([verb isEqualToString:@"DELETE"])
    {
        return RKRequestMethodDELETE;
    }
    else if([verb isEqualToString:@"PUT"])
    {
        return RKRequestMethodPUT;
    }
    else
    {
        return RKRequestMethodGET;
    }
}

- (RestKitObjectLoaderDelegate *) loaderDelegate:(id<SMRequestDelegate>)requestDelegate
{
    return [[[RestKitObjectLoaderDelegate alloc] initWithRequestDelegate:requestDelegate andRequest:self] autorelease];
}

- (void) onRequestComplete
{
    _requestFinished = YES;
}

- (void)sendRequest
{
	_requestFinished = NO;
    //RKRequestMethod
    SMLogVerbose(@"RestKit method: %@", self.method);
    SMLogVerbose(@"Request Request with url: %@", self.url);
    SMLogVerbose(@"Request Request with HTTP Method: %@", self.httpMethod);
    SMLog(@"httpMethod %@", [self httpMethod]);
    
    RestKitObjectLoaderDelegate *loaderDelegate = [self loaderDelegate:self.delegate];
    RKRequestMethod method = [self requestMethodFromString:self.httpMethod];
    [self.objectManager sendObject:mObject delegate:loaderDelegate block:^(RKObjectLoader* l) {
        l.method = method;
        l.targetObject = nil;
        [[l additionalHTTPHeaders] setValue:@"gzip" forKey:@"Accept-Encoding"];
        [[l additionalHTTPHeaders] setValue:@"deflate" forKey:@"Accept-Encoding"];
    }];
}

- (void)cancel
{
	//[self.connection cancel];
	//self.connection = nil;
}

- (id) sendSynchronousRequestProvidingError:(NSError**)error {    
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) sendSynchronousRequest {
    
    /*
     if (kLogVersbose == YES) {
     SMLog(@"RestkitRequest %p: Sending Synch Request httpMethod=%@ method=%@ url=%@", self, self.httpMethod, self.method, self.url);
     }
     
     OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey
     secret:session.apiSecret];
     
     OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.url
     consumer:consumer
     token:nil   // we don't need a token
     realm:nil   // should we set a realm?
     signatureProvider:nil]; // use the default method, HMAC-SHA1
     [consumer release];
     [request setHTTPMethod:[self httpMethod]];
     
     [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
     [request addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
     [request prepare];
     if (![[self httpMethod] isEqualToString: @"GET"]) {
     [request setHTTPBody:[[mArguments yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];	
     NSString *contentType = [NSString stringWithFormat:@"application/json"];
     [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
     }
     
     [mConnectionData setLength:0];
     
     if (kLogVersbose) {
     SMLog(@"StackMobRequest %p: sending synchronous oauth request: %@", self, request);
     }
     
     _requestFinished = NO;
     self.connectionError = nil;
     self.delegate = nil;
     self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
     
     NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
     while (!_requestFinished && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil]) {
     loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
     }
     
     return self.result;
     */
    return nil;
}

- (void) dealloc
{
    [_authClient release];
    [_objectManager release];
    [super dealloc];
}

@end
