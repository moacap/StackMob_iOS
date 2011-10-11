//
//  RestKitConfiguration.h
//  StackMobiOS
//
//  Created by Ryan Connelly on 10/9/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestKitConfiguration : NSObject
{
    RKObjectMappingProvider *mappingProvider;
    RKClient *client;
    RKObjectRouter *router;
    BOOL inferMappingsFromObjectTypes;
}

@property (nonatomic, retain) RKObjectMappingProvider *mappingProvider;
@property (nonatomic, retain) RKClient *client;
@property (nonatomic, retain) RKObjectRouter *router;
@property BOOL inferMappingsFromObjectTypes;
@end
