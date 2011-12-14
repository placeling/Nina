//
//  MemberRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-10.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "User.h"
#import "NSDictionary+Utility.h"
#import "NinaAppDelegate.h"

@implementation User

@synthesize userId, city;
@synthesize iconURLString, description;
@synthesize username, profilePic, placeCount;
@synthesize followingCount, followerCount;
@synthesize following, follows_you, modified;
@synthesize email, url, location, auths;

- (id)initFromJsonDict:(NSDictionary *)jsonDict{    
    if(self = [super init]){
        self.auths = [[[NSMutableDictionary alloc] init] autorelease];
        [self updateFromJsonDict:jsonDict];
	}
	return self;
}

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.userId = [jsonDict objectForKeyNotNull:@"id"];
    self.username = [jsonDict objectForKeyNotNull:@"username"];
    self.city = [jsonDict objectForKeyNotNull:@"city"];
    self.placeCount = [[jsonDict objectForKeyNotNull:@"perspectives_count"] intValue];
    self.followerCount =[[jsonDict objectForKeyNotNull:@"follower_count"] intValue];
    self.followingCount = [[jsonDict objectForKeyNotNull:@"following_count"] intValue];
    self.description = [jsonDict objectForKeyNotNull:@"description"];
    self.url = [jsonDict objectForKeyNotNull:@"url"];
    self.email = [jsonDict objectForKeyNotNull:@"email"];
    
    self.location = [jsonDict objectForKeyNotNull:@"location"];
    
    self.following = [[jsonDict objectForKeyNotNull:@"following"] boolValue];
    self.follows_you = [[jsonDict objectForKeyNotNull:@"follows_you"] boolValue];
    
    [self.auths removeAllObjects];
    if ([jsonDict objectForKey:@"facebook"]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ( ![defaults objectForKey:@"FBAccessTokenKey"] ){
            [defaults setObject:[[jsonDict objectForKey:@"facebook"] objectForKey:@"token"] forKey:@"FBAccessTokenKey"];
            [defaults setObject:[[jsonDict objectForKey:@"facebook"] objectForKey:@"expiry"] forKey:@"FBExpirationDateKey"];
            [defaults synchronize];
        }
        
        [self.auths setObject:[jsonDict objectForKey:@"facebook"] forKey:@"facebook"];
    }
    
    Photo *photo = [[Photo alloc] init];
    photo.thumb_url = [jsonDict objectForKeyNotNull:@"thumb_url"];
    photo.main_url = [jsonDict objectForKeyNotNull:@"main_url"];
    self.profilePic = photo;
    
    [photo release];
    
}

-(NSString*) userThumbUrl{
    if (self.profilePic && self.profilePic.thumb_url && [self.profilePic.thumb_url length] >0){
        return self.profilePic.thumb_url;
    } else {
        return @"http://www.placeling.com/images/default_profile.png";
    }
}

-(NSDictionary*) facebook{
    
    if ([self.auths objectForKey:@"facebook"]){
        return [self.auths objectForKey:@"facebook"];        
    } else {
        return nil;
    }
    
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
    [auths release];
    
    [super dealloc];
}

@end
