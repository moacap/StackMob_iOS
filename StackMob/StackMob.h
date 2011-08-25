//
//  StackMob.h
//  MeetingRoom
//
//  Created by Josh Stephenson on 7/10/11.
//  Copyright 2011 StackMob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackMobSession.h"
#import "StackMobRequest.h"

typedef void (^StackMobCallback)(BOOL success, id result);

@interface StackMob : NSObject <SMRequestDelegate>{
    NSMutableArray *callbacks;
    NSMutableArray *requests;
    StackMobSession *session;
    StackMobRequest *currentRequest;
    BOOL _running;
}

@property (nonatomic, retain) StackMobSession *session;
@property (nonatomic, retain) NSMutableArray *callbacks;
@property (nonatomic, retain) NSMutableArray *requests;

+ (StackMob *)stackmob;

- (void)loginWithFacebookToken:(NSString *)facebookToken andCallback:(StackMobCallback)callback;
- (void)registerWithFacebookToken:(NSString *)facebookToken username:(NSString *)username andCallback:(StackMobCallback)callback;

- (void)get:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;
- (void)get:(NSString *)path withCallback:(StackMobCallback)callback;

- (void)customGet:(NSString *)path withCallback:(StackMobCallback)callback;
- (void)customGet:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

- (void)post:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;
- (void)post:(NSString *)path forUser:(NSString *)user withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

- (void)customPost:(NSString *)path withCallback:(StackMobCallback)callback;

- (void)put:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;
- (void)destroy:(NSString *)path withParams:(NSDictionary *)params andCallback:(StackMobCallback)callback;

- (void)startSession;
- (void)endSession;

@end
