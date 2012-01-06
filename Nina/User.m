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

@dynamic userId, city, userDescription;
@dynamic username, profilePic, placeCount;
@dynamic followingCount, followerCount;
@dynamic following, follows_you;
@dynamic email, url; 
@synthesize auths, modified, location;

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.userId = [jsonDict objectForKeyNotNull:@"id"];
    self.username = [jsonDict objectForKeyNotNull:@"username"];
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
    
    self.auths = [[[NSMutableDictionary alloc] init] autorelease];
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
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *managedObjectContext = objectManager.objectStore.managedObjectContext;
    Photo *photo = [[Photo alloc] initWithEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
    
    photo.thumbUrl = [jsonDict objectForKeyNotNull:@"thumb_url"];
    photo.mainUrl = [jsonDict objectForKeyNotNull:@"main_url"];
    self.profilePic = photo;
    
    [photo release];
    
}

-(NSString*) userThumbUrl{
    if (self.profilePic && self.profilePic.thumbUrl && [self.profilePic.thumbUrl length] >0){
        return self.profilePic.thumbUrl;
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


+(RKManagedObjectMapping*)getObjectMapping{
    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForClass:[User class]];
    [userMapping mapKeyPathsToAttributes:
     @"id", @"userId",
     @"username", @"username",
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
     nil];
    
    userMapping.primaryKeyAttribute = @"username";
    [userMapping mapKeyPath:@"picture" toRelationship:@"profilePic" withMapping:[Photo getObjectMapping]];
    
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
    [followerCount release]; 
    
    [super dealloc];
}

@end
