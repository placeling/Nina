//
//  LocationRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-30.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Place.h"
#import "NSDictionary+Utility.h"


@implementation Place

@synthesize name, pid, user;
@synthesize address, city, perspectiveCount, bookmarked, followingPerspectiveCount;
@synthesize location, usersBookmarking;
@synthesize place_id, phone, googlePlacesUrl;
@synthesize categories, icon, tags;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        self.pid = [jsonDict objectForKeyNotNull:@"_id"];
        self.name = [jsonDict objectForKeyNotNull:@"name"];
        self.address = [jsonDict objectForKeyNotNull:@"street_address"];
        self.city = [jsonDict objectForKeyNotNull:@"city_data"];
        self.phone = [jsonDict objectForKeyNotNull:@"phone_number"];
        self.place_id = [jsonDict objectForKeyNotNull:@"google_id"];
        self.googlePlacesUrl = [jsonDict objectForKeyNotNull:@"google_url"];
        NSNumber *lat = [[jsonDict objectForKey:@"location"] objectAtIndex:0];
        NSNumber *lng = [[jsonDict objectForKey:@"location"] objectAtIndex:1]; 
        
        self.location = [[[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]]autorelease];
        self.perspectiveCount = [[jsonDict objectForKeyNotNull:@"perspective_count"] intValue];
        self.bookmarked = [[jsonDict objectForKeyNotNull:@"bookmarked"] boolValue] ;
        self.categories = [jsonDict objectForKeyNotNull:@"venue_types"];
        
        self.usersBookmarking = [jsonDict objectForKey:@"users_bookmarking"];        
        self.followingPerspectiveCount = [[jsonDict objectForKey:@"following_perspective_count"] intValue];
        self.tags = [jsonDict objectForKeyNotNull:@"tags"];
	}
	return self;
}

-(NSString*) usersBookmarkingString{
    
    if ( [self.usersBookmarking count] ==1){
        return [NSString stringWithFormat:@"%@", [self.usersBookmarking objectAtIndex:0]];
    } else if ([self.usersBookmarking count] ==2){
        return [NSString stringWithFormat:@"%@ & %@", [self.usersBookmarking objectAtIndex:0], [self.usersBookmarking objectAtIndex:1]];
    } else if ([self.usersBookmarking count] > 2){
        return [NSString stringWithFormat:@"%@ & %i others you follow", [self.usersBookmarking objectAtIndex:0], [self.usersBookmarking count] -1];
    } else {
        DLog(@"Warning: had 0 usersbookmarking but called for string");
        return @"";
    }
}

- (void) dealloc{
    [name release];
    [pid release];
    [user release];
    [address release];
    [city release];
    [place_id release];
    [phone release];
    [location release];
    [usersBookmarking release];
    [tags release];

    [categories release];
    [icon release];
    
    [super dealloc];
}

@end
