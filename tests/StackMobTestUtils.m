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

#import "StackMobTestUtils.h"

NSString * const kAPIKey = @"201543b9-7b81-4934-a353-c22d979c891a";
NSString * const kAPISecret = @"7a099db4-e09a-4e71-8348-3fea8ef5164f";
NSString * const kSubDomain = @"stackmob";
NSString * const kAppName = @"iossdktest";
NSInteger  const kVersion = 0;

@implementation StackMobTestUtils

+ (void)runRunLoop:(NSRunLoop *)runLoop untilRequestFinished:(StackMobRequest *)request
{
    do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
}

+ (id)runDefaultRunLoopAndGetDictionaryResultFromRequest:(StackMobRequest *)request
{
    [self runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
    return request.result;
}

@end
