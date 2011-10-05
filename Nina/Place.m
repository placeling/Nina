//
//  LocationRecord.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-30.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Place.h"


@implementation Place

@synthesize name, pid, user;
@synthesize address, city, perspectiveCount, bookmarked, followingPerspectiveCount;
@synthesize location, usersBookmarking;
@synthesize place_id, phone, googlePlacesUrl;
@synthesize categories, icon;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        self.pid = [jsonDict objectForKey:@"_id"];
        self.name = [jsonDict objectForKey:@"name"];
        self.address = [jsonDict objectForKey:@"street_address"];
        self.city = [jsonDict objectForKey:@"city_data"];
        self.phone = [jsonDict objectForKey:@"phone_number"];
        self.place_id = [jsonDict objectForKey:@"google_id"];
        self.googlePlacesUrl = [jsonDict objectForKey:@"google_url"];
        NSNumber *lat = [[jsonDict objectForKey:@"location"] objectAtIndex:0];
        NSNumber *lng = [[jsonDict objectForKey:@"location"] objectAtIndex:1]; 
        
        self.location = [[[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]]autorelease];
        self.perspectiveCount = [[jsonDict objectForKey:@"perspective_count"] intValue];
        self.bookmarked = [[jsonDict objectForKey:@"bookmarked"] boolValue] ;
        self.categories = [jsonDict objectForKey:@"venue_types"];
        
        self.usersBookmarking = [jsonDict objectForKey:@"users_bookmarking"];
        
        self.followingPerspectiveCount = [[jsonDict objectForKey:@"following_perspective_count"] intValue];
        
        

        
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

    [categories release];
    [icon release];
    
    [super dealloc];
}

@end
