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

@synthesize userId, city, userDescription;
@synthesize username, fullname, profilePic, placeCount, highlightedCount;
@synthesize followingCount, followerCount, perspectives;
@synthesize following, follows_you, lat, lng;
@synthesize email, url; 
@synthesize auths, location, blocked, timestamp, notificationCount;

- (id) init
{
    if (self = [super init]){
        timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
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
     @"highlighted_count", @"highlightedCount",
     @"description", @"userDescription",
     @"url", @"url",
     @"email", @"email",
     @"lat", @"lat",
     @"lng", @"lng",
     @"location", @"location",
     @"following", @"following",
     @"follows_you", @"follows_you",
     @"blocked", @"blocked",
     @"notification_count", @"notificationCount",
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
    [highlightedCount release];
    [notificationCount release];
    [perspectives release];
    [lat release];
    [lng release];
    
    [super dealloc];
}

@end
