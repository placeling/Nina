//
//  MemberRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-10.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userId, city;
@synthesize iconURLString, description;
@synthesize username, profilePic, placeCount;
@synthesize followingCount, followerCount;

- (id)initFromJsonDict:(NSDictionary *)jsonDict{    
    if(self = [super init]){
        self.userId = [jsonDict objectForKey:@"id"];
        self.username = [jsonDict objectForKey:@"username"];
        self.placeCount = [[jsonDict objectForKey:@"perspective_count"] intValue];
        self.followerCount =[[jsonDict objectForKey:@"follower_count"] intValue];
        self.followingCount = [[jsonDict objectForKey:@"following_count"] intValue];
        self.description = [jsonDict objectForKey:@"description"];
	}
	return self;
}

- (void)dealloc{
    [username release];
    [super dealloc];
}

@end