//
//  StackMobTestUtils.h
//  StackMobiOS
//
//  Created by Aaron Schlesinger on 11/14/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMob.h"

@interface StackMobTestUtils : NSObject
+ (void)setStackMobApplication;
+ (void)runRunLoop:(NSRunLoop *)runLoop untilRequestFinished:(StackMobRequest *)request;
+ (NSDictionary *)runDefaultRunLoopAndGetDictionaryResultFromRequest:(StackMobRequest *)request;
@end
