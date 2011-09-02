//
//  PlaceDetail.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Perspective.h"


@implementation Perspective
@synthesize user, place, notes, tags, photos;
@synthesize starred;
@synthesize dateAdded, visited, share, mine;
@synthesize perspectiveId;

-(id) initFromJsonDict:(NSDictionary *)jsonDict{
    
    if(self = [super init]){
        self.place = [[Place alloc] initFromJsonDict:[jsonDict objectForKey:@"place"]];
        [self updateFromJsonDict:jsonDict];
	}
	return self;
}

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    //self.tags = [jsonDict objectForKey:@"tags"];
    self.perspectiveId = [jsonDict objectForKey:@"_id"];
    self.notes = [jsonDict objectForKey:@"memo"];
    self.starred = [[jsonDict objectForKey:@"starred"] boolValue];
    mine = [[jsonDict objectForKey:@"mine"] boolValue];
}

- (void) dealloc {
    [user release];
    [place release];
    [notes release];
    [tags release];
    [photos release];
    [dateAdded release];
    [perspectiveId release];
    [super dealloc];
}

@end
