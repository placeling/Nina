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
@synthesize address, city, mapCount, bookmarked;
@synthesize location;
@synthesize google_id, phone, googlePlacesUrl;
@synthesize categories, icon;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        self.pid = [jsonDict objectForKey:@"_id"];
        self.name = [jsonDict objectForKey:@"name"];
        self.address = [jsonDict objectForKey:@"street_address"];
        self.city = [jsonDict objectForKey:@"city_data"];
        self.phone = [jsonDict objectForKey:@"phone_number"];
        self.google_id = [jsonDict objectForKey:@"google_id"];
        self.googlePlacesUrl = [jsonDict objectForKey:@"google_url"];
        NSNumber *lat = [[jsonDict objectForKey:@"location"] objectAtIndex:0];
        NSNumber *lng = [[jsonDict objectForKey:@"location"] objectAtIndex:1];        
        self.location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
        self.mapCount = [[jsonDict objectForKey:@"perspective_count"] intValue];
        self.bookmarked = [[jsonDict objectForKey:@"bookmarked"] boolValue] ;
        self.categories = [jsonDict objectForKey:@"venue_types"];
        
	}
	return self;
}

- (void) dealloc{
    [name release];
    [pid release];
    [user release];
    [address release];
    [city release];
    [google_id release];
    [phone release];
    [location release];

    [categories release];
    [icon release];
    
    [super dealloc];
}

@end
