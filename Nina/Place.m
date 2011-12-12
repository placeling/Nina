//
//  LocationRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-30.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Place.h"
#import "NSDictionary+Utility.h"
#import "NinaHelper.h"

@implementation Place

@synthesize dirty, name, pid, user;
@synthesize address, city, perspectiveCount, bookmarked, followingPerspectiveCount;
@synthesize location, usersBookmarking;
@synthesize place_id, phone, googlePlacesUrl, google_ref, thumb_url=_thumb_url;
@synthesize categories, icon, tags;
@synthesize homePerspectives,followingPerspectives,everyonePerspectives;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        [self updateFromJsonDict:jsonDict];
        self.dirty = false;
	}
	return self;
}


-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.pid = [jsonDict objectForKeyNotNull:@"_id"];
    self.name = [jsonDict objectForKeyNotNull:@"name"];
    self.address = [jsonDict objectForKeyNotNull:@"street_address"];
    self.city = [jsonDict objectForKeyNotNull:@"city_data"];
    self.phone = [jsonDict objectForKeyNotNull:@"phone_number"];
    
    self.place_id = [jsonDict objectForKeyNotNull:@"google_id"];
    self.googlePlacesUrl = [jsonDict objectForKeyNotNull:@"google_url"];
    self.google_ref = [jsonDict objectForKey:@"google_ref"];
    
    NSNumber *lat = [[jsonDict objectForKey:@"location"] objectAtIndex:0];
    NSNumber *lng = [[jsonDict objectForKey:@"location"] objectAtIndex:1]; 
    
    self.location = [[[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]]autorelease];
    self.perspectiveCount = [[jsonDict objectForKeyNotNull:@"perspective_count"] intValue];
    self.bookmarked = [[jsonDict objectForKeyNotNull:@"bookmarked"] boolValue] ;
    self.categories = [jsonDict objectForKeyNotNull:@"venue_types"];
    
    self.usersBookmarking = [jsonDict objectForKey:@"users_bookmarking"];        
    self.followingPerspectiveCount = [[jsonDict objectForKey:@"following_perspective_count"] intValue];
    self.tags = [jsonDict objectForKeyNotNull:@"tags"];
    self.thumb_url = [jsonDict objectForKey:@"thumb_url"];
}

-(NSString*) usersBookmarkingString{
    
    if ( [self.usersBookmarking count] ==1){
        return [NSString stringWithFormat:@"%@", [self.usersBookmarking objectAtIndex:0]];
    } else if ([self.usersBookmarking count] ==2){
        return [NSString stringWithFormat:@"%@ & %@", [self.usersBookmarking objectAtIndex:0], [self.usersBookmarking objectAtIndex:1]];
    } else if ([self.usersBookmarking count] > 2){
        return [NSString stringWithFormat:@"%@ & %i others", [self.usersBookmarking objectAtIndex:0], [self.usersBookmarking count] -1];
    } else {
        DLog(@"Warning: had 0 users bookmarking but called for string");
        return @"";
    }
}

-(NSString*)tagString{
    NSMutableArray *cleanedTags = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *tag in self.tags){ 
        if ([tag hasPrefix:@"#"]) {
            [cleanedTags addObject:tag];
        } else {
            [cleanedTags addObject:[NSString stringWithFormat:@"#%@", tag]];
        }
    }
    return [cleanedTags componentsJoinedByString:@", "];
}

-(NSString*) placeThumbUrl{
    /*
        NSString *mapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%ix%i&markers=color:red%%7C%f,%f&sensor=false&scale=2", self.place.location.coordinate.latitude, self.place.location.coordinate.longitude, 90, 90, self.place.location.coordinate.latitude, self.place.location.coordinate.longitude]; */
    
    
    if (_thumb_url == nil || [thumb_url length] ==0){
        return @"http://www.placeling.com/images/placeling_thumb_logo.png";
    } else {
        return _thumb_url;
    }
    
}

-(float) distance{
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *userLocation = manager.location;
    
	if (userLocation != nil){ 
        float target = [userLocation distanceFromLocation:self.location];
        return target;
    } else {
        return 0.0;
    }
    
}

- (void) dealloc{
    [name release];
    [pid release];
    [user release];
    [address release];
    [city release];
    [place_id release];
    [google_ref release];
    
    [phone release];
    [location release];
    [usersBookmarking release];
    [tags release];

    [categories release];
    [icon release];
    [_thumb_url release];
    
    [homePerspectives release];
    [followingPerspectives release];
    [everyonePerspectives release];
    
    [super dealloc];
}

@end
