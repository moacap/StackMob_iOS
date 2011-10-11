//
//  RestKitObjectLoaderDelegate.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobRequest.h"
@class SMRequestDelegate, RestKitRequest;
@interface RestKitObjectLoaderDelegate : NSObject <RKObjectLoaderDelegate>
{
    id<SMRequestDelegate> requestDelegate;
    RestKitRequest *_request;
}

- (id) initWithRequestDelegate:(id<SMRequestDelegate>) delegate andRequest:(RestKitRequest *)request;

@property (nonatomic, assign) RestKitRequest *request;
@property (nonatomic, retain) id<SMRequestDelegate> requestDelegate;
@end
