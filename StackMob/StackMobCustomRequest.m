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
