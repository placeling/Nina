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
@synthesize following, follows_you;

- (id)initFromJsonDict:(NSDictionary *)jsonDict{    
    if(self = [super init]){
        self.userId = [jsonDict objectForKey:@"id"];
        self.username = [jsonDict objectForKey:@"username"];
        self.placeCount = [[jsonDict objectForKey:@"perspectives_count"] intValue];
        self.followerCount =[[jsonDict objectForKey:@"follower_count"] intValue];
        self.followingCount = [[jsonDict objectForKey:@"following_count"] intValue];
        self.description = [jsonDict objectForKey:@"description"];
        
        self.following = [[jsonDict objectForKey:@"following"] boolValue];
        self.follows_you = [[jsonDict objectForKey:@"follows_you"] boolValue];
	}
	return self;
}

- (void)dealloc{    
    [userId release];
    [city release];
    [iconURLString release];
    [username release];
    [description release];
    [profilePic release];
    
    [super dealloc];
}

@end
