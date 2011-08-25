//
//  StackMobUserRequest.h
//  MeetingRoom
//
//  Created by Josh Stephenson on 8/24/11.
//  Copyright (c) 2011 StackMob. All rights reserved.
//
#import "StackMobRequest.h"

typedef enum {
    SMUserRequestGet,
    SMUserRequestPost,
    SMUserRequestPut,
    SMUserRequestDelete,
    SMUserRequestLogin,
    SMUserRequestLogout,
    SMUserRequestCreateUserWithFacebook,
    SMUserRequestLinkUserWithFacebook,
    SMUserRequestFacebookLogin,
    SMUserRequestPostFacebookMessage,
    SMUserRequestGetFacebookUserInfo,
    SMUserRequestCreateUserWithTwitter,
    SMUserRequestLinkUserWithTwitter,
    SMUserRequestTwitterLogin,
    SMUserRequestTwitterStatusUpdate
} SMUserRequest;

@interface StackMobUserRequest : StackMobRequest

@end
