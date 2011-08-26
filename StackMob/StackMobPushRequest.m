//
//  StackMobPushRequest.m
//  StackMobiOS
//
//  Created by dav on 6/9/11.
//  Copyright 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobPushRequest.h"

@implementation StackMobPushRequest

+ (StackMobRequest*)request	{
	return [[[StackMobPushRequest alloc] init] autorelease];
}

- (NSURL*)getURL {
	NSString* stringURL = [session pushURL];
	return [NSURL URLWithString: stringURL];
}

@end
