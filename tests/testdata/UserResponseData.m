//
//  UserResponseData.m
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "UserResponseData.h"

@implementation UserResponseData
@synthesize email;
@synthesize firstname;
@synthesize lastname;
@synthesize lastmoddate;
@synthesize createddate;
@synthesize username;

- (void) dealloc
{
    [createddate release];
    [email release];
    [firstname release];
    [lastname release];
    [lastmoddate release];
    [username release];
    
    [super dealloc];
}

- (BOOL) isEqual:(id)object
{
    return ([email isEqualToString:[object email]] &&
            [firstname isEqualToString:[object firstname]] &&
            [lastname isEqualToString:[object lastname]] &&
            [lastmoddate isEqual:[object lastmoddate]] &&
            [username isEqualToString:[object username]]);
}

@end
