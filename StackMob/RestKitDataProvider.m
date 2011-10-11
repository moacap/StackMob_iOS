// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "RestkitDataProvider.h"
#import "RestKitRequest.h"
#import "StackMobRequest.h"
#import "StackMobPushRequest.h"
#import "RestKitConfiguration.h"
#import "StackMob.h"
#import "StackMobSession.h"

@interface RestkitDataProvider (Private)
- (void) prepareRouter:(RKObjectRouter *)router withRequest:(RestKitRequest *)request;
@end

@implementation RestkitDataProvider
@synthesize restKitConfiguration;

+ (void) initialize
{
    NSSet* JSONParserClassNames = [NSSet setWithObjects:@"RKJSONParserJSONKit", @"RKJSONParserYAJL", @"RKJSONParserSBJSON", @"RKJSONParserNXJSON", nil];    
    for (NSString* parserClassName in JSONParserClassNames) {
        Class parserClass = NSClassFromString(parserClassName);
        if (parserClass) {
            [[RKParserRegistry sharedRegistry] setParserClass:parserClass forMIMEType:@"application/json charset=utf-8"];
            break;
        }
    }
}

- (void) prepareRequest:(RestKitRequest *)request
{
    if([self.restKitConfiguration client])
        request.objectManager.client = [self.restKitConfiguration client];
    
    if([self.restKitConfiguration mappingProvider])
        request.objectManager.mappingProvider = [self.restKitConfiguration mappingProvider];
    
    if([self.restKitConfiguration router])
    {
        request.objectManager.router = [self.restKitConfiguration router];
        [self prepareRouter:request.objectManager.router withRequest:request];
    }
    
    request.objectManager.inferMappingsFromObjectTypes = self.restKitConfiguration.inferMappingsFromObjectTypes;
}

/* Appends the base path to the relative path. Required because RestKit OAuth expects 
   the full relative path. */
- (void) prepareRouter:(RKObjectRouter *)router withRequest:(RestKitRequest *)request
{
    StackMobSession *sess = [[StackMob stackmob] session];
    NSString *path = [[NSURL URLWithString:sess.apiURL] relativePath];    
    if([request userBased])
    {
        [path stringByAppendingFormat:@"/%@",sess.userObjectName];
    }
    NSMutableDictionary *routes = [request.objectManager.router routes];
    for( NSString *className in [routes allKeys] )
    {
        NSMutableDictionary *classRoutes = [routes objectForKey:className];
        for( NSString *method in [classRoutes allKeys] )
        {
            NSMutableDictionary *routeEntry = [classRoutes objectForKey:method];
            // prepend the base path
            NSString *resourcePath = [path stringByAppendingString:[routeEntry objectForKey:@"resourcePath"]];
            // update the resource path with the new value;
            [routeEntry setObject:resourcePath forKey:@"resourcePath"];
        }
    }
}

- (StackMobRequest *)request
{
    RestKitRequest *request = [RestKitRequest request];
    [self prepareRequest:request];
    return request;
}

- (StackMobRequest *)userRequest
{
    return [RestKitRequest userRequest];
}

- (StackMobRequest *)requestForMethod:(NSString*)method
{
	return [RestKitRequest requestForMethod:method withHttpVerb:GET];
}	

- (StackMobRequest *)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [RestKitRequest requestForMethod:method withObject:nil withHttpVerb:httpVerb];
}

- (StackMobRequest *)requestForMethod:(NSString*)method withObject:(id)object  withHttpVerb:(SMHttpVerb)httpVerb
{
	RestKitRequest *request =  [RestKitRequest requestForMethod:method withObject:object withHttpVerb:httpVerb];
    [self prepareRequest:request];
    return request;
}

- (StackMobRequest *)requestForMethod:(NSString *)method withData:(NSData *)data{
    return [RestKitRequest requestForMethod:method withData:data];
}

- (StackMobRequest *)userRequestForMethod:(NSString *)method withHttpVerb:(SMHttpVerb)httpVerb
{
	return [RestKitRequest userRequestForMethod:method withObject:nil withHttpVerb:httpVerb];    
}

- (StackMobRequest *)userRequestForMethod:(NSString*)method withObject:(id)object withHttpVerb:(SMHttpVerb)httpVerb
{
	return [RestKitRequest userRequestForMethod:method withObject:object withHttpVerb:httpVerb];
}

/*
 * Create a request for an iOS PUSH notification
 @param arguments a dictionary of arguments including :alert, :badge and :sound
 */
- (StackMobPushRequest *)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb
{
    return [StackMobRequest pushRequestWithArguments:arguments withHttpVerb:httpVerb];
}

- (StackMobPushRequest *)pushRequest
{
    return [StackMobPushRequest request];
}
- (void) dealloc
{
    [restKitConfiguration release];
    [super dealloc];
}

@end
