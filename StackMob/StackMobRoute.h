//
//  StackMobRoute.h
//  MeetingRoom
//
//  Created by Josh Stephenson on 8/24/11.
//  Copyright (c) 2011 StackMob. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum {
    SMCustomURLCreateWithFacebook,
    SMCustomURLLinkWithFacebook,
    SMCustomURLFacebookLogin,
    SMCustomURLPostFacebookMessage,
    SMCustomURLGetFacebookUser,
    SMCustomURLCreateWithTwitter
} SMCustomURL;

@interface StackMobRoute : NSObject {

}

- (NSURL *)url;

@end
