//
//  NSData+JSON.m
//  MeetingRoom
//
//  Created by Josh Stephenson on 8/6/11.
//  Copyright 2011 StackMob. All rights reserved.
//

#import "NSData+JSON.h"
#import "NSData+Base64.h"

@implementation NSData (JSON)

- (id)JSON
{
    return [NSString stringWithFormat:@"Content-Type: image/png\n\
Content-Disposition: attachment; filename=img.png\n\
Content-Transfer-Encoding: base64\n\n\
%@",
             [self base64EncodedString]];
}

@end
