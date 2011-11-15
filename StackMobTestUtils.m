//
//  StackMobTestUtils.m
//  StackMobiOS
//
//  Created by Aaron Schlesinger on 11/14/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobTestUtils.h"

NSString * const kAPIKey = @"TEST_APP_PUB_KEY";
NSString * const kAPISecret = @"TEST_APP_PUB_KEY";
NSString * const kSubDomain = @"TEST_APP_SUBDOMAIN";
NSString * const kAppName = @"TEST_APP_NAME";
NSInteger  const kVersion = 0;

@implementation StackMobTestUtils

+ (void)setStackMobApplication {
    [StackMob setApplication:kAPIKey secret:kAPISecret appName:kAppName subDomain:kSubDomain userObjectName:@"user" apiVersionNumber:[NSNumber numberWithInt:kVersion]];
}

+ (void)runRunLoop:(NSRunLoop *)runLoop untilRequestFinished:(StackMobRequest *)request
{
    do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
}

+ (NSDictionary *)runDefaultRunLoopAndGetDictionaryResultFromRequest:(StackMobRequest *)request
{
    [self runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
    return request.result;
}

@end
