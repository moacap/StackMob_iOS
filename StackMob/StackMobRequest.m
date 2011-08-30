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

#import "StackMobRequest.h"
#import "Reachability.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "StackMobClientData.h"
#import "StackMobSession.h"
#import "StackMobPushRequest.h"
#import "NSData+JSON.h"

@interface StackMobRequest (Private)
+ (NSString*)stringFromHttpVerb:(SMHttpVerb)httpVerb;
@end

@implementation StackMobRequest;

@synthesize connection = mConnection;
@synthesize delegate = mDelegate;
@synthesize method = mMethod;
@synthesize result = mResult;
@synthesize body = mBody;
@synthesize httpMethod = mHttpMethod;
@synthesize httpResponse = mHttpResponse;
@synthesize finished = _requestFinished;
@synthesize userBased;

# pragma mark - Memory Management
- (void)dealloc
{
	SMLogVerbose(@"StackMobRequest: dealloc");
	[self cancel];
	[mConnectionData release];
	[mConnection release];
	[mDelegate release];
	[mMethod release];
	[mResult release];
	[mHttpMethod release];
	[mHttpResponse release];
    [mBody release];
	[super dealloc];
	SMLogVerbose(@"StackMobRequest: dealloc finished");
}

# pragma mark - Initialization

+ (id)request	
{
	return [[[StackMobRequest alloc] init] autorelease];
}

+ (id)userRequest
{
    StackMobRequest *request = [StackMobRequest request];
    request.userBased = YES;
    return request;
}

+ (id)requestForMethod:(NSString*)method
{
	return [StackMobRequest requestForMethod:method withHttpVerb:GET];
}	

+ (id)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest requestForMethod:method withArguments:nil withHttpVerb:httpVerb];
}

+ (id)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [StackMobRequest userRequestForMethod:method withArguments:nil withHttpVerb:httpVerb];    
}

+ (id)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments  withHttpVerb:(SMHttpVerb)httpVerb
{
	StackMobRequest* request = [StackMobRequest request];
	request.method = method;
	request.httpMethod = [self stringFromHttpVerb:httpVerb];
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}

+ (id)userRequestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb
{
	StackMobRequest* request = [StackMobRequest userRequest];
	request.method = method;
	request.httpMethod = [self stringFromHttpVerb:httpVerb];
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}

+ (id)requestForMethod:(NSString *)method withData:(NSData *)data{
    StackMobRequest *request = [StackMobRequest request];
    request.method = method;
    request.httpMethod = [self stringFromHttpVerb:POST];
    request.body = data;
    return request;
}

+ (id)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb {
	StackMobRequest* request = [StackMobPushRequest request];
	request.httpMethod = [self stringFromHttpVerb:httpVerb];
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}

+ (NSString*)stringFromHttpVerb:(SMHttpVerb)httpVerb {
	switch (httpVerb) {
		case POST:
			return @"POST";	
		case PUT:
			return @"PUT";
		case DELETE:
			return @"DELETE";	
		default:
			return @"GET";
	}
}

- (NSURL*)getURL
{
    // nil method is an invalid request
	if(!self.method) return nil;
    
    // add query string
    NSMutableArray *urlComponents = [NSMutableArray arrayWithCapacity:2];
    [urlComponents addObject:[session urlForMethod:self.method isUserBased:userBased]];
	if ([[self httpMethod] isEqualToString:@"GET"] &&
		[mArguments count] > 0) {
		[urlComponents addObject:[mArguments queryString]];
	}
    
    NSString *urlString = [urlComponents componentsJoinedByString:@"?"];
    SMLogVerbose(@"%@", urlString);
    
	return [NSURL URLWithString:urlString];
}

- (NSInteger)getStatusCode
{
	return [mHttpResponse statusCode];
}


- (id)init
{
	self = [super init];
    if(self){
        self.delegate = nil;
        self.method = nil;
        self.result = nil;
        mArguments = [[NSMutableDictionary alloc] init];
        mConnectionData = [[NSMutableData alloc] init];
        mResult = nil;
        session = [StackMobSession session];
    }
	return self;
}

#pragma mark -

- (void)setArguments:(NSDictionary*)arguments
{
	[mArguments setDictionary:arguments];
}

- (void)setValue:(NSString*)value forArgument:(NSString*)argument
{
	[mArguments setValue:value forKey:argument];
}

- (void)setInteger:(NSUInteger)value forArgument:(NSString*)argument
{
	[mArguments setValue:[NSString stringWithFormat:@"%u", value] forKey:argument];
}

- (void)setBool:(BOOL)value forArgument:(NSString*)argument
{
	[mArguments setValue:(value ? @"true" : @"false") forKey:argument];
}


- (void)sendRequest
{
	_requestFinished = NO;

    SMLogVerbose(@"StackMob method: %@", self.method);
    SMLogVerbose(@"Request Request with url: %@", self.url);
    SMLogVerbose(@"Request Request with HTTP Method: %@", self.httpMethod);
				
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey
														secret:session.apiSecret];
				
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.url
																   consumer:consumer
																	  token:nil
																	  realm:nil
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
    SMLog(@"httpMethod %@", [self httpMethod]);
	[request setHTTPMethod:[self httpMethod]];
		
	[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
	[request prepare];
	if (![[self httpMethod] isEqualToString: @"GET"]) {
        NSData* postData = [[mArguments yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
        SMLogVerbose(@"POST Data: %d", [postData length]);
        [request setHTTPBody:postData];	
        NSString *contentType = [NSString stringWithFormat:@"application/json"];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"]; 
	}
		
    SMLogVerbose(@"StackMobRequest: sending asynchronous oauth request: %@", request);
    
	[mConnectionData setLength:0];		
	self.result = nil;
	self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain]; // Why retaining this when already retained by synthesized method?
}

- (void)cancel
{
	[self.connection cancel];
	self.connection = nil;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	mHttpResponse = [(NSHTTPURLResponse*)response copy];
}
	
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	if (!data) {
		SMLog(@"StackMobRequest: Received data but it was nil");
		return;
	}

	[mConnectionData appendData:data];
	
    SMLogVerbose(@"StackMobRequest: Got data of length %u", [mConnectionData length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_requestFinished = YES;
    
	SMLog(@"Connection failed! Error - %@", [error localizedDescription]);
    
	// inform the user
	self.result = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], @"statusDetails", nil];  
	if (self.delegate && [self.delegate respondsToSelector:@selector(requestCompleted:)])
        [[self delegate] requestCompleted:self];
}


- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	_requestFinished = YES;
	if(kLogRequestSteps) SMLog(@"Received Request: %@", self.method);
  
	NSString *textResult = nil;
	NSDictionary *result = nil;
    NSInteger statusCode = [self getStatusCode];

    SMLogVerbose(@"RESPONSE CODE %d", statusCode);
    if ([mConnectionData length] > 0) {
        textResult = [[[NSString alloc] initWithData:mConnectionData encoding:NSUTF8StringEncoding] autorelease];
        SMLogVerbose(@"RESPONSE BODY %@", textResult);
    }

    // If it's a 500, it probably isn't JSON so don't attempt to parse it as such
    if (statusCode < 500) {
        if (textResult == nil) {
            result = [NSDictionary dictionary];
        }
        else {
            @try{
                [mConnectionData setLength:0];
                result = [textResult yajl_JSON];
            }
            @catch (NSException *e) {
                result = nil;
                SMLog(@"Unable to parse json '%@'", textResult);
            }
        }
    }
  
    if (kLogRequestSteps)
        SMLog(@"Request Processed: %@", self.method);

    self.result = result;
	
    if (!self.delegate) SMLogVerbose(@"No delegate");
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(requestCompleted:)]){
        SMLogVerbose(@"Calling delegate %d, self %d", [mDelegate retainCount], [self retainCount]);
        [self.delegate requestCompleted:self];
    } else {
        SMLogVerbose(@"Delegate does not respond to selector\ndelegate: %@", mDelegate);
    }
}

- (id)sendSynchronousRequestProvidingError:(NSError**)error {
    SMLogVerbose(@"Sending Request: %@", self.method);
    SMLogVerbose(@"Request URL: %@", self.url);
    SMLogVerbose(@"Request HTTP Method: %@", self.httpMethod);
	
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey
													secret:session.apiSecret];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.url
																   consumer:consumer
																	  token:nil   // we don't need a token
																	  realm:nil   // should we set a realm?
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
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
	NSURLResponse *response = nil;

    SMLogVerbose(@"StackMobRequest: sending synchronous oauth request: %@", request);
    
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    if (error)
        SMLogVerbose(@"StackMobRequest: ERROR: %@", [*error localizedDescription]);

	[mConnectionData appendData:data];
    mHttpResponse = [(NSHTTPURLResponse*)response copy];

	NSDictionary* result = nil;
	
	if ([mConnectionData length] == 0){
		result = [NSDictionary dictionary];
	}
	else{
        NSString* textResult = [[[NSString alloc] initWithData:mConnectionData encoding:NSUTF8StringEncoding] autorelease];
		SMLogVerbose(@"Text result was %@", textResult);
		
		[mConnectionData setLength:0];
        @try{
            result = [textResult yajl_JSON];
        }
        @catch (NSException *e){
            SMLog(@"Unable to parse json for '%@'", textResult);
        }
	}
	return result;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"%@: %@", [super description], self.url];
}
	
	
@end
