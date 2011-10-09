//
//  MemberRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-10.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "User.h"
#import "NSDictionary+Utility.h"

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
    self.userId = [jsonDict objectForKeyNotNull:@"id"];
    self.username = [jsonDict objectForKeyNotNull:@"username"];
    self.placeCount = [[jsonDict objectForKeyNotNull:@"perspectives_count"] intValue];
    self.followerCount =[[jsonDict objectForKeyNotNull:@"follower_count"] intValue];
    self.followingCount = [[jsonDict objectForKeyNotNull:@"following_count"] intValue];
    self.description = [jsonDict objectForKeyNotNull:@"description"];
    self.url = [jsonDict objectForKeyNotNull:@"url"];
    self.email = [jsonDict objectForKeyNotNull:@"email"];
    
    self.location = [jsonDict objectForKeyNotNull:@"location"];
    
    self.following = [[jsonDict objectForKeyNotNull:@"following"] boolValue];
    self.follows_you = [[jsonDict objectForKeyNotNull:@"follows_you"] boolValue];
    
    Photo *photo = [[Photo alloc] init];
    photo.thumb_url = [jsonDict objectForKeyNotNull:@"thumb_url"];
    photo.main_url = [jsonDict objectForKeyNotNull:@"main_url"];
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
