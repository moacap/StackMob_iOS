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


#import "APIRequestTests.h"

NSString * const kAPIKey = @"8ae11219-1950-48a4-a3bc-8cf31e077941";
NSString * const kAPISecret = @"f5874341-a158-4fbf-8e0d-dd92ac791adc";
NSString * const kSubDomain = @"stackmob";
NSString * const kAppName = @"sdktestapp";
NSInteger  const kVersion = 1;

StackMobSession *mySession = nil;

@implementation APIRequestTests

- (void) setUp
{
	NSLog(@"In setup");
	if (!mySession) 
	{
        [StackMob setApplication:kAPIKey secret:kAPISecret appName:kAppName subDomain:kSubDomain userObjectName:@"user" apiVersionNumber:[NSNumber numberWithInt:kVersion]];
//		mySession = [StackMobSession sessionForApplication:kAPIKey secret:kAPISecret 
//													appName:kAppName subDomain:kSubDomain apiVersionNumber:[NSNumber numberWithInt:kVersion]];
		NSLog(@"Created new session");
	}
}

- (void) tearDown
{
	NSLog(@"In teardown");
	mySession = nil;
}

- (void) testGet {
    NSMutableDictionary* userArgs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
											@"ty", @"lastName",
											nil];
	
	StackMobRequest *request = [StackMobRequest requestForMethod:@"user" 
												   withArguments:userArgs
												  withHttpVerb:GET];
	[request sendRequest];
	//we need to loop until the request comes back, its just a test its OK
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
	
	NSLog(@"testGet result was: %@", [request result]);
	request = nil;
	[userArgs release];
    NSLog(@"Finished Get Test");

}

- (void) testPost {
	NSLog(@"IN TEST POST");
    NSMutableDictionary* userArgs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
										@"Ty", @"firstName",
										@"Amell", @"lastName",
										@"ty@stackmob.com", @"email",
										nil];
	
    StackMobRequest *request = [[StackMob stackmob] post:@"user" withArguments:userArgs andCallback:^(BOOL success, id result){
        if(success){
            NSLog(@"testPost result was: %@", result);
            NSDictionary *info = (NSDictionary *)result;
            NSString *userId = [info objectForKey:@"user_id"];
            STAssertNotNil(userId, @"Returned value for POST is not correct");
        }
        else{
            STFail(@"creating a user failed");
        }
    }];

	//we need to loop until the request comes back, its just a test its OK
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
	
	NSDictionary *result = [request result];
    NSLog(@"result %@", result);
	NSString *userId = [result objectForKey:@"userId"];
	STAssertNotNil(userId, @"Returned value for POST is not correct");
	request = nil;
	[userArgs release];
}



- (void) testURLGeneration {

	StackMobRequest *request = [StackMobRequest requestForMethod: @"user"];
	NSURL *testURL = [NSURL URLWithString: @"http://stackmob.stackmob.com/api/1/sdktestapp/user"];
    NSLog(@"expected %@", [testURL absoluteString]),
    NSLog(@"actual %@", [request.url absoluteString]);
	STAssertTrue([[testURL absoluteString] isEqualToString: 
				  [request.url absoluteString]], @"User get URLs do not match" );
	testURL = nil;
	request = nil;
	
}

- (void) testAPIList {
	
	StackMobRequest *request = [StackMobRequest requestForMethod: @"apilist"];
	NSLog(@"Calling sendSynchronousRequest");
    NSError *error = nil;
	NSDictionary *result = [request sendSynchronousRequestProvidingError:&error];
	NSLog(@"TestAPIList result was: %@", result);
	request = nil;
	
	
}





@end
