//
//  MemberRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-10.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize city;
@synthesize iconURLString;
@synthesize username, profilePic, placeCount;

- (void)dealloc{
    
    [username release];
    [profilePic release];
    [placeCount release];
    [city release];
	[iconURLString release];
    
    [super dealloc];
}

@end
