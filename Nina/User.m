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
#import "NinaHelper.h"

@implementation User

@synthesize userId, city, userDescription;
@synthesize username, fullname, profilePic, placeCount;
@synthesize followingCount, followerCount, perspectives;
@synthesize following, follows_you;
@synthesize email, url; 
@synthesize auths, modified, location, blocked;

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.userId = [jsonDict objectForKeyNotNull:@"id"];
    self.username = [jsonDict objectForKeyNotNull:@"username"];
    self.fullname = [jsonDict objectForKeyNotNull:@"fullname"];
    self.city = [jsonDict objectForKeyNotNull:@"city"];
    self.placeCount = [NSNumber numberWithInt:[[jsonDict objectForKeyNotNull:@"perspectives_count"] intValue]];
    self.followerCount = [NSNumber numberWithInt:[[jsonDict objectForKeyNotNull:@"follower_count"] intValue]];
    self.followingCount = [NSNumber numberWithInt:[[jsonDict objectForKeyNotNull:@"following_count"] intValue]];
    self.userDescription = [jsonDict objectForKeyNotNull:@"description"];
    self.url = [jsonDict objectForKeyNotNull:@"url"];
    self.email = [jsonDict objectForKeyNotNull:@"email"];
    
    self.location = [jsonDict objectForKeyNotNull:@"location"];
    
    self.following =[NSNumber numberWithBool:[[jsonDict objectForKeyNotNull:@"following"] boolValue]];
    self.follows_you = [NSNumber numberWithBool:[[jsonDict objectForKeyNotNull:@"follows_you"] boolValue]]; 
    
    self.auths = [[[NSMutableArray alloc] init] autorelease];
    self.blocked = [[jsonDict objectForKeyNotNull:@"blocked"] boolValue] ;
    
    for ( NSDictionary *authDict in [jsonDict objectForKey:@"auths"] ){
        
        if ([[authDict objectForKey:@"provider"] isEqualToString:@"facebook"] ){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ( ![defaults objectForKey:@"FBAccessTokenKey"] ){
                [defaults setObject:[authDict objectForKey:@"token"] forKey:@"FBAccessTokenKey"];
                [defaults setObject:[authDict objectForKey:@"expiry"] forKey:@"FBExpirationDateKey"];
                [defaults synchronize];
            } 
        }
        
        Authentication *auth = [[Authentication alloc] init];
        auth.provider = [authDict objectForKey:@"provider"];
        auth.uid = [authDict objectForKey:@"uid"];
        auth.expiry = [authDict objectForKey:@"expiry"];
        auth.token = [authDict objectForKey:@"token"];
        
        [self.auths addObject:auth];
        [auth release];
        
    }
    
    Photo *photo = [[[Photo alloc] init] autorelease];
    
    photo.thumbUrl = [jsonDict objectForKeyNotNull:@"thumb_url"];
    photo.mainUrl = [jsonDict objectForKeyNotNull:@"main_url"];
    self.profilePic = photo;
    
    //[photo release];
    
}

-(NSString*) userThumbUrl{
    if (self.profilePic && self.profilePic.thumbUrl && [self.profilePic.thumbUrl length] >0){
        return self.profilePic.thumbUrl;
    } else {
        return @"http://www.placeling.com/images/default_profile.png";
    }
}

-(NSDictionary*) facebook{
    
    if ([self.auths count] > 0){
        return [self.auths objectAtIndex:0];        
    } else {
        return nil;
    }    
}


+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping mapKeyPathsToAttributes:
     @"id", @"userId",
     @"username", @"username",
     @"fullname", @"fullname",
     @"city", @"city",
     @"perspectives_count", @"placeCount",
     @"follower_count", @"followerCount",
     @"following_count", @"followingCount",
     @"description", @"userDescription",
     @"url", @"url",
     @"email", @"email",
     @"location", @"location",
     @"following", @"following",
     @"follows_you", @"follows_you",
     @"blocked", @"blocked",
     nil];
    
    //userMapping.primaryKeyAttribute = @"username";
    [userMapping mapKeyPath:@"picture" toRelationship:@"profilePic" withMapping:[Photo getObjectMapping]];
    
    [userMapping mapKeyPath:@"auths" toRelationship:@"auths" withMapping:[Authentication getObjectMapping]];
    
    return userMapping;
}


- (void)dealloc{    
    [userId release];
    [city release];
    [username release];
    [userDescription release];
    [profilePic release];
    [email release];
    [url release];
    [location release];
    [auths release];
    [placeCount release];
    [followingCount release];
    [fullname release];
    [followerCount release]; 
    [perspectives release];
    
    [super dealloc];
}

@end
