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
@synthesize email, url, location;

- (id)initFromJsonDict:(NSDictionary *)jsonDict{    
    if(self = [super init]){
        [self updateFromJsonDict:jsonDict];
	}
	return self;
}

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.userId = [jsonDict objectForKey:@"id"];
    self.username = [jsonDict objectForKey:@"username"];
    self.placeCount = [[jsonDict objectForKey:@"perspectives_count"] intValue];
    self.followerCount =[[jsonDict objectForKey:@"follower_count"] intValue];
    self.followingCount = [[jsonDict objectForKey:@"following_count"] intValue];
    self.description = [jsonDict objectForKey:@"description"];
    self.url = [jsonDict objectForKey:@"url"];
    self.email = [jsonDict objectForKey:@"email"];
    
    self.location = [jsonDict objectForKey:@"location"];
    
    self.following = [[jsonDict objectForKey:@"following"] boolValue];
    self.follows_you = [[jsonDict objectForKey:@"follows_you"] boolValue];
    
    Photo *photo = [[Photo alloc] init];
    photo.thumb_url = [jsonDict objectForKey:@"thumb_url"];
    photo.main_url = [jsonDict objectForKey:@"main_url"];
    self.profilePic = photo;
    
    [photo release];
    
}

- (void)dealloc{    
    [userId release];
    [city release];
    [iconURLString release];
    [username release];
    [description release];
    [profilePic release];
    [email release];
    [url release];
    [location release];
    
    [super dealloc];
}

@end
