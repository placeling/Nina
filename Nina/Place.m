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
@synthesize address, mapCount, bookmarked;
@synthesize lat, lng;
@synthesize google_id, phone;
@synthesize categories, icon;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        self.pid = [jsonDict objectForKey:@"_id"];
        self.name = [jsonDict objectForKey:@"name"];
        self.address = [jsonDict objectForKey:@"street_address"];
        self.phone = [jsonDict objectForKey:@"phone_number"];
        self.google_id = [jsonDict objectForKey:@"google_id"];
        self.lat = [[jsonDict objectForKey:@"location"] objectAtIndex:0];
        self.lng = [[jsonDict objectForKey:@"location"] objectAtIndex:1];
        self.mapCount = [jsonDict objectForKey:@"perspective_count"];
        self.bookmarked = [[jsonDict objectForKey:@"bookmarked"] boolValue] ;
        //user;
        //categories;
        //icon;
        
	}
	return self;
}

- (void) dealloc{
    [name release];
    [pid release];
    [user release];
    [address release];
    
    [lat release];
    [lng release];
    [google_id release];
    [phone release];
    [mapCount release];

    [categories release];
    [icon release];
    
    [super dealloc];
}

@end
