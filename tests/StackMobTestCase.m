//
//  RestKitProviderTests.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobTestCase.h"
#import "StackMob.h"

#import <UIKit/UIKit.h>
//#import "application_headers" as required


NSString * const kAPIKey = @"201543b9-7b81-4934-a353-c22d979c891a";
NSString * const kAPISecret = @"7a099db4-e09a-4e71-8348-3fea8ef5164f";
NSString * const kSubDomain = @"stackmob";
NSString * const kAppName = @"iossdktest";
NSInteger  const kVersion = 0;

@implementation StackMobTestCase
@synthesize session;

- (void) setUp
{
	NSLog(@"In setup");
	if (!session) 
	{
        StackMob *stackMob = [StackMob setApplication:kAPIKey secret:kAPISecret appName:kAppName subDomain:kSubDomain userObjectName:@"user" apiVersionNumber:[NSNumber numberWithInt:kVersion]];
        
        self.session = [stackMob session];
		NSLog(@"Created new session");
	}
}

- (void) tearDown
{
	NSLog(@"In teardown");
    [session release];
	session = nil;
}

@end
