//
//  DataProviderProtocol.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMobRequest.h"
#import "StackMobBulkRequest.h"

@class StackMobPushRequest, StackMobRequest;

/** 
 *  @abstract The STMDataProvider defines the interface
 *  by which the StackMob singleton bridge class interacts with the 
 *  implementation. There are two implementations: STMRestKitDataProvider and STMDynamicDataProvider.
 *
 */
@protocol STMDataProvider <NSObject>

- (StackMobRequest *)request;
- (StackMobRequest *)userRequest;

/* REQUEST */

/* 
 * Standard CRUD requests
 */
- (StackMobRequest *)request;
- (StackMobRequest *)requestForMethod:(NSString*)method;
- (StackMobRequest *)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb) httpVerb;
- (StackMobRequest *)requestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb) httpVerb;
+ (StackMobRequest *)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb;
/* 
 * User based requests 
 * Use these to 
 */
- (StackMobRequest *)userRequest;
- (StackMobRequest *)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb;
- (StackMobRequest *)userRequestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb;

/*
 * Create a bulk request to send multiple requests
 @param object
 */
- (StackMobBulkRequest *)bulkRequestForMethod:(NSString *)method withObject:(id)object withHttpVerb:(SMHttpVerb) httpVerb;
- (StackMobBulkRequest *)bulkRequest;

/*
 * Create a request for an iOS PUSH notification
 @param arguments a dictionary including :alert, :badge and :sound
 */
- (StackMobPushRequest *)pushRequestWithArguments:(NSDictionary *)arguments withHttpVerb:(SMHttpVerb) httpVerb;
- (StackMobPushRequest *)pushRequest;

/* Called after session has been started*/
- (void) prepare;

@end
