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
@synthesize following, follows_you, lat, lng;
@synthesize email, url; 
@synthesize auths, location, blocked, timestamp;

- (id) init
{
    if (self = [super init]){
        timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

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
            NSString *expiry = [authDict objectForKey:@"expiry"];
            NSDateFormatter *jsonFormatter = [RKObjectMapping preferredDateFormatter];
            
            if ( ![defaults objectForKey:@"FBAccessTokenKey"] ){
                [defaults setObject:[authDict objectForKey:@"token"] forKey:@"FBAccessTokenKey"];
                DLog(@"Parsing Auth Expirty Date %@",[jsonFormatter dateFromString:expiry]);
                [defaults setObject:[jsonFormatter dateFromString:expiry] forKey:@"FBExpirationDateKey"];
                [defaults synchronize];
                NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
                
                appDelegate.facebook = [[[Facebook alloc] initWithAppId:[NinaHelper getFacebookAppId] andDelegate:appDelegate] autorelease];
                
                appDelegate.facebook.accessToken = [authDict objectForKey:@"token"];
                appDelegate.facebook.expirationDate = [jsonFormatter dateFromString:expiry];
            } 

            Authentication *auth = [[Authentication alloc] init];
            auth.provider = [authDict objectForKey:@"provider"];
            auth.uid = [authDict objectForKey:@"uid"];
            auth.expiry = [jsonFormatter dateFromString:expiry];
            auth.token = [authDict objectForKey:@"token"];
            
            [self.auths addObject:auth];
            [auth release];
        }
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

-(Authentication*) facebook{    
    for (Authentication *auth in self.auths){
        if ([auth.provider isEqualToString:@"facebook"]){
            return auth;
        }
    }
    
    return nil;
}

-(Authentication*) twitter{
    for (Authentication *auth in self.auths){
        if ([auth.provider isEqualToString:@"twitter"]){
            return auth;
        }
    }
    
    return nil;
}

-(CLLocationCoordinate2D)homeLocation{
    CLLocationCoordinate2D loc;
    loc.latitude = [lat floatValue];
    loc.longitude = [lng floatValue];
    return loc;
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
     @"lat", @"lat",
     @"lng", @"lng",
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

#pragma mark Fgallerydelegate


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery{
    return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index{
    return FGalleryPhotoSourceTypeNetwork;//always network for these
}


- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index{
    if (size == FGalleryPhotoSizeFullsize){
        return  self.profilePic.mainUrl;
    } else {
        return self.profilePic.thumbUrl;
    }
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
    [lat release];
    [lng release];
    
    [super dealloc];
}

@end
