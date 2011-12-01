//
//  StackMobQueryTests.m
//  StackMobiOS
//
//  Created by Jordan West on 11/30/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobQueryTests.h"

#import <UIKit/UIKit.h>

@implementation StackMobQueryTests

- (void)testBasicOperators {
    StackMobQuery *q = [StackMobQuery query];
    [q field:@"equal" mustEqualValue:@"a"];
    [q field:@"lt" mustBeLessThanValue:[NSNumber numberWithInt:1]];
    [q field:@"lte" mustBeLessThanOrEqualToValue:[NSNumber numberWithInt:2]];
    [q field:@"gt" mustBeGreaterThanValue:[NSNumber numberWithInt:3]];
    [q field:@"gte" mustBeGreaterThanOrEqualToValue:[NSNumber numberWithInt:4]];
    [q field:@"in" mustBeOneOf:[NSArray arrayWithObject:@"hi"]];
    
    NSString *equal = [q.params objectForKey:@"equal"];
    NSNumber *lt = [q.params objectForKey:@"lt[lt]"];
    NSNumber *lte = [q.params objectForKey:@"lte[lte]"];
    NSNumber *gt = [q.params objectForKey:@"gt[gt]"];
    NSNumber *gte = [q.params objectForKey:@"gte[gte]"];
    NSArray *ina = [q.params objectForKey:@"in[in]"];


    STAssertTrue([equal isEqualToString:@"a"], @"equal failed");
    STAssertTrue([lt isEqualToNumber:[NSNumber numberWithInt:1]], @"lt failed");
    STAssertTrue([lte isEqualToNumber:[NSNumber numberWithInt:2]], @"lte failed");
    STAssertTrue([gt isEqualToNumber:[NSNumber numberWithInt:3]], @"gt failed");
    STAssertTrue([gte isEqualToNumber:[NSNumber numberWithInt:4]], @"gte failed");
    STAssertTrue([ina isEqualToArray:[NSArray arrayWithObject:@"hi"]], @"in failed");
}

@end
