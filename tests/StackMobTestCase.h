//
//  RestKitProviderTests.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/10/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
@class StackMobSession;
@interface StackMobTestCase : SenTestCase
{
    StackMobSession *session;
}
@property (nonatomic, retain)  StackMobSession *session;

@end


extern NSString * const kAPIKey;
extern NSString * const kAPISecret;
extern NSString * const kSubDomain;
extern NSString * const kAppName;
extern NSInteger  const kVersion;

