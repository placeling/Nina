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
#import "Perspective.h"

@implementation Place

@synthesize dirty, name, pid, user;
@synthesize streetAddress, city, perspectiveCount, followingPerspectiveCount;
@synthesize lat, lng, usersBookmarking, bookmarked, highlighted;
@synthesize googleId, phone, googlePlacesUrl, google_ref, thumbUrl, mapUrl, highlightUrl;
@synthesize categories, icon, tags, hidden, slug;
@synthesize homePerspectives,followingPerspectives,everyonePerspectives, placemarks, attributions;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* placeMapping = [Place getObjectMappingNoPerspectives];     
                                     
    [placeMapping mapKeyPath:@"perspectives" toRelationship:@"homePerspectives" withMapping:[Perspective getObjectMapping]];
    
    [placeMapping mapKeyPath:@"placemarks" toRelationship:@"placemarks" withMapping:[Perspective getObjectMapping]];
    
    return placeMapping;
}

+(RKObjectMapping*)getObjectMappingNoPerspectives{
    RKObjectMapping* placeMapping = [RKObjectMapping mappingForClass:[Place class]];
    [placeMapping mapKeyPathsToAttributes:
     
     @"id", @"pid",
     @"name", @"name",
     @"street_address", @"streetAddress", 
     @"city_data", @"city",     
     @"perspective_count", @"perspectiveCount",
     @"venue_types", @"categories",
     @"google_url", @"googlePlacesUrl",
     @"google_id", @"googleId",
     @"google_ref", @"google_ref",
     @"bookmarked", @"bookmarked",
     @"highlighted", @"highlighted",
     @"users_bookmarking", @"usersBookmarking",
     @"following_perspective_count", @"followingPerspectiveCount",
     @"tags", @"tags",
     @"thumb_url", @"thumbUrl",
     @"highlight_url", @"highlightUrl",
     @"map_url", @"mapUrl",
     @"slug", @"slug",
     @"html_attributions", @"attributions",
     nil];
    
    [placeMapping mapKeyPath:@"lat" toAttribute:@"lat"];
    [placeMapping mapKeyPath:@"lng" toAttribute:@"lng"];
    
    return placeMapping;
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
    
    
    if (self.thumbUrl == nil || [self.thumbUrl length] ==0){
        return @"http://www.placeling.com/images/placeling_thumb_logo.png";
    } else {
        return self.thumbUrl;
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

-(CLLocation*) location{
    return [[[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]]autorelease];
    
}

- (void) dealloc{
    [name release];
    [pid release];
    [user release];
    [streetAddress release];
    [city release];
    [googleId release];
    [google_ref release];
    [slug release];
    
    [phone release];
    [lat release];
    [lng release];
    [usersBookmarking release];
    [tags release];

    [categories release];
    [icon release];
    [thumbUrl release];
    [highlightUrl release];
    [mapUrl release];
    
    [homePerspectives release];
    [followingPerspectives release];
    [everyonePerspectives release];
    [placemarks release];
    
    [attributions release];
    
    [super dealloc];
}

@end
