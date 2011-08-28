// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

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

@implementation StackMobRequest;

@synthesize connection = mConnection;
@synthesize delegate = mDelegate;
@synthesize method = mMethod;
@synthesize result = mResult;
@synthesize connectionError = _connectionError;
@synthesize httpMethod = mHttpMethod;
@synthesize httpResponse = mHttpResponse;
@synthesize finished = _requestFinished;


+ (StackMobRequest*)request	
{
	return [[[StackMobRequest alloc] init] autorelease];
}

+ (StackMobRequest*)requestForMethod:(NSString*)method
{
	return [StackMobRequest requestForMethod:method withHttpVerb:GET];
}	

+ (StackMobRequest*)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb) httpVerb
{
	return [StackMobRequest requestForMethod:method withArguments:nil withHttpVerb:httpVerb];

}	

+ (StackMobRequest*)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments  withHttpVerb:(SMHttpVerb) httpVerb
{
	StackMobRequest* request = [StackMobRequest request];
	request.method = method;
	request.httpMethod = [self stringFromHttpVerb:httpVerb];
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}

+ (StackMobRequest*)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb {
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
	if (self.method == nil)
		return nil;
	NSMutableString *stringURL = [session urlForMethod:self.method];
	if ([[self httpMethod] isEqualToString: @"GET"] &&
		[mArguments count] > 0) {
		[stringURL appendString: @"?"];
		[stringURL appendString: [mArguments queryString]];
	}
	return [NSURL URLWithString: stringURL];
}

- (NSInteger)getStatusCode
{
	return [mHttpResponse statusCode];
}


- (id)init	
{
	self = [super init];
	if (self == nil)
		return nil;
	self.delegate = nil;
	self.method = nil;
	self.result = nil;
	mArguments = [[NSMutableDictionary alloc] init];
	mConnectionData = [[NSMutableData alloc] init];
	mResult = nil;
	session = [StackMobSession session];
	return self;
}

- (void)dealloc
{
	if (kLogVersbose == YES)
		StackMobLog(@"StackMobRequest %p: dealloc", self);
	[self cancel];
	[mConnectionData release];
	[mConnection release];
	[mDelegate release];
	[mMethod release];
	[mResult release];
	[mHttpMethod release];
	[mHttpResponse release];
	[super dealloc];
	if (kLogVersbose == YES)
		StackMobLog(@"StackMobRequest %p: dealloc finished", self);
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

	if (kLogVersbose == YES) {
		StackMobLog(@"StackMobRequest %p: Sending Asynch Request httpMethod=%@ method=%@ url=%@", self, self.httpMethod, self.method, self.url);
	}
				
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey secret:session.apiSecret];
		
		//TODO: This should be its own call?
//		StackMobClientData *data = [StackMobClientData sharedClientData];
//		[self setValue:[data clientDataString]  forArgument:@"cd"];
				
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.url
																   consumer:consumer
																	  token:nil
																	  realm:nil
                        signatureProvider:nil]; // use the default method, HMAC-SHA1
  [consumer release];
	[request setHTTPMethod:[self httpMethod]];
		
	[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
	[request prepare];
	if (![[self httpMethod] isEqualToString: @"GET"]) {
    NSData* postData = [[mArguments yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    if (kLogVersbose == YES) {
      StackMobLog(@"StackMobRequest %p: POST Data: %@", self, postData);
    }
		[request setHTTPBody:postData];	
		NSString *contentType = [NSString stringWithFormat:@"application/json"];
		[request addValue:contentType forHTTPHeaderField: @"Content-Type"]; 
	}
		
	if (kLogVersbose) {
		StackMobLog(@"StackMobRequest %p: sending asynchronous oauth request: %@", self, request);
	}
	[mConnectionData setLength:0];		
	self.result = nil;
  self.connectionError = nil;
	self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain]; // Why retaining this when already retained by synthesized method?
  [request release];
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
	if (data == nil) {
		StackMobLog(@"StackMobRequest %p: Recieved data but it was nil", self);
		return;
	}

	[mConnectionData appendData:data];
	
	if (kLogVersbose == YES)
		StackMobLog(@"StackMobRequest %p: Got data of length %u", self, [mConnectionData length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_requestFinished = YES;
  self.connectionError = error;
	// inform the user
	StackMobLog(@"StackMobRequest %p: Connection failed! Error - %@ %@",
    self,
		[error localizedDescription],
		[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	self.result = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], @"statusDetails", nil];  
	// If a delegate has been set, attempt to tell
	// it all about this request's status.
	if (self.delegate != nil)
	{
		// If a selector has been set for this request, 
		// attempt to notify the delegate using it.
		if ([self.delegate respondsToSelector:@selector(requestCompleted:)] == YES)
			[[self delegate] requestCompleted:self];
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	_requestFinished = YES;
	if (kLogRequestSteps == YES) 
    StackMobLog(@"StackMobRequest %p: Received Request: %@", self, self.method);
  
	NSString*     textResult = nil;
	NSDictionary* result = nil;
  NSInteger statusCode = [self getStatusCode];

  if ([mConnectionData length] != 0) {
    textResult = [[[NSString alloc] initWithData:mConnectionData encoding:NSUTF8StringEncoding] autorelease];
    StackMobLog(@"StackMobRequest %p: Text result was %@", self, textResult);
  }

  // If it's a 500, it probably isn't JSON so don't attempt to parse it as such
  if (statusCode != 500) {
    if (textResult == nil) {
      result = [NSDictionary dictionary];
    }	else {
      [mConnectionData setLength:0];		
      result = [textResult yajl_JSON];
    }
  }
  
	if (kLogRequestSteps == YES)
		StackMobLog(@"StackMobRequest %p: Request Processed: %@", self, self.method);


	self.result = result;
	
	// If a delegate has been set, attempt to tell
	// it all about this request's status.
	if (mDelegate != nil)
	{
		if ([mDelegate respondsToSelector:@selector(requestCompleted:)] == YES) {
      if (kLogVersbose == YES) {
        StackMobLog(@"StackMobRequest %p: Calling delegate", self);
      }
			[mDelegate requestCompleted:self];
    } else {
      if (kLogVersbose == YES) {
        StackMobLog(@"StackMobRequest %p: Delegate does not respond to selector\ndelegate: %@", self, mDelegate);
      }
    }
	
	} else {
    if (kLogVersbose == YES) {
      StackMobLog(@"StackMobRequest %p: No delegate", self);
    }
  }
}

- (id) sendSynchronousRequestProvidingError:(NSError**)error {
  id result = [self sendSynchronousRequest];
  *error = self.connectionError;
  return result;
}

- (id) sendSynchronousRequest {
	if (kLogVersbose == YES) {
		StackMobLog(@"StackMobRequest %p: Sending Synch Request httpMethod=%@ method=%@ url=%@", self, self.httpMethod, self.method, self.url);
	}
	
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey
													secret:session.apiSecret];
	
	//TODO: This should be its own call?
	//		StackMobClientData *data = [StackMobClientData sharedClientData];
	//		[self setValue:[data clientDataString]  forArgument:@"cd"];
	
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
		StackMobLog(@"StackMobRequest %p: sending synchronous oauth request: %@", self, request);
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
}

- (NSString*) description {
  return [NSString stringWithFormat:@"%@: %@", [super description], self.url];
}
	
	
@end
