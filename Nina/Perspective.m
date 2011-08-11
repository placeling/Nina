//
//  PlaceDetail.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Perspective.h"


@implementation Perspective
@synthesize user, place, notes, tags, photos, starred, dateAdded, visited, share;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        self.place = [[Place alloc] initFromJsonDict:[jsonDict objectForKey:@"place"]];

        //self.tags = [jsonDict objectForKey:@"tags"];
        self.notes = [jsonDict objectForKey:@"memo"];
        self.starred = [jsonDict objectForKey:@"favorite"]; 
        
	}
	return self;
}

- (void) dealloc
{
    [user release];
    [place release];
    [notes release];
    [tags release];
    [photos release];
    [dateAdded release];
    [super dealloc];
}

@end