//
//  StackMobCustomRequest.m
//  MeetingRoom
//
//  Created by Josh Stephenson on 8/23/11.
//  Copyright 2011 StackMob. All rights reserved.
//

#import "StackMobCustomRequest.h"

@implementation StackMobCustomRequest

+ (id)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb)httpVerb
{
	StackMobCustomRequest *request = [[[StackMobCustomRequest alloc] init] autorelease];
	request.method = method;
	request.httpMethod = [self stringFromHttpVerb:httpVerb];
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}


- (NSURL*)getURL {
    
    // TODO: refactor this
    NSString *urlString = [NSString stringWithFormat:@"http://%@.%@/api/%@/%@/heroku/proxy/%@", session.subDomain, session.domain, session.apiVersionNumber, session.appName, self.method];
	return [NSURL URLWithString:urlString];
}

@end
