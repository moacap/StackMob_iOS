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

#import "StackMobPushTests.h"

#import <UIKit/UIKit.h>
//#import "application_headers" as required

NSString * PUSH_USER = @"IOS_TEST_PUSH_USER";
NSString * PUSH_TOKEN = @"DEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF";
NSDictionary * PUSH_PAYLOAD = nil;
StackMobCallback EMPTY_CB = ^(BOOL success, id result) {};

@implementation StackMobPushTests

- (void)assertResultIsQueued:(NSDictionary *)result {
    STAssertNotNil([result objectForKey:@"queued"], @"no queued value returned");
}

- (void)registerToken {
    StackMobRequest * request = [[StackMob stackmob] registerForPushWithUser:PUSH_USER token:PUSH_TOKEN andCallback:EMPTY_CB];
    [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
}

- (void)setUp {
    [StackMobTestUtils setStackMobApplication];
    if(!PUSH_PAYLOAD) {
        PUSH_PAYLOAD = [NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"key1", nil];
    }
    if(!PUSH_USER_TARGETS) {
        PUSH_USER_TARGETS = [NSArray arrayWithObject:PUSH_USER];
    }
    if(!PUSH_TOKEN_TARGETS) {
        PUSH_TOKEN_TARGETS = [NSArray arrayWithObject:PUSH_TOKEN];
    }
    
    StackMobRequest * request = [[StackMob stackmob] deletePushToken:PUSH_TOKEN andCallback:EMPTY_CB];
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
}

- (void)tearDown {
    StackMobRequest * request = [[StackMob stackmob] deletePushToken:PUSH_TOKEN andCallback:EMPTY_CB];
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
}

- (void)testRegisterDeviceToken {
    StackMobRequest * request = [[StackMob stackmob] registerForPushWithUser:PUSH_USER token:PUSH_TOKEN andCallback:EMPTY_CB];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    STAssertTrue((BOOL)[result objectForKey:@"registered"], @"token not reported as registered");
}

- (void)testGetDeviceTokens {
    StackMobRequest * request = [[StackMob stackmob] getPushTokensForUsers:[NSArray arrayWithObject:PUSH_USER] andCallback:EMPTY_CB];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    STAssertNotNil([result objectForKey:@"tokens"], @"no tokens value returned");
}


- (void)testSendPushBroadcastWithArguments {
    StackMobRequest * request = [[StackMob stackmob] sendPushBroadcastWithArguments:PUSH_PAYLOAD andCallback:EMPTY_CB];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertResultIsQueued:result];
}

- (void)testSendPushToUsersWithArguments {
    [self registerToken];
    
    StackMobRequest * request = [[StackMob stackmob] sendPushToUsersWithArguments:PUSH_PAYLOAD withUserIds:PUSH_USER_TARGETS andCallback:EMPTY_CB];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertResultIsQueued:result];
}

- (void)testSendPushToTokensWithArguments {
    [self registerToken];
    
    StackMobRequest * request = [[StackMob stackmob] sendPushToTokensWithArguments:PUSH_PAYLOAD withTokens:PUSH_TOKEN_TARGETS andCallback:EMPTY_CB];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertResultIsQueued:result];
}

@end