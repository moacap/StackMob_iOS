//
//  StackMobQuery.m
//  StackMobiOS
//
//  Created by Jordan West on 10/14/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobQuery.h"

@implementation StackMobQuery

@synthesize params = _params;

+ (StackMobQuery *)query {
    return [[[StackMobQuery alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        _params = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    return self;
}

- (void)field:(NSString *)f mustEqualValue:(id)v {
    [self.params setValue:v forKey:f];
}

- (void)field:(NSString *)f mustBeLessThanValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[lt]", f]];
}

- (void)field:(NSString *)f mustBeLessThanOrEqualToValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[lte]", f]];
}

- (void)field:(NSString *)f mustBeGreaterThanValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[gt]", f]];
}

- (void)field:(NSString *)f mustBeGreaterThanOrEqualToValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[gte]", f]];        
}

- (void)field:(NSString *)f mustBeOneOf:(NSArray *)arr {
    [self.params setValue:arr forKey:[NSString stringWithFormat:@"%@[in]", f]];
}

- (void)setExpandDepth:(NSUInteger)depth {
    [self.params setValue:[NSNumber numberWithInt:depth] forKey:@"_expand"];
}

- (void)dealloc {
    self.params = nil;
    [super dealloc];
}

@end
