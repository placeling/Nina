//
//  PlaceDetail.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Perspective.h"


@implementation Perspective
@synthesize user, place, notes, tags, photos, starred, lastModified;
@synthesize dateAdded, visited, share, mine, perspectiveId;

-(id) initFromJsonDict:(NSDictionary *)jsonDict{
    if(self = [super init]){
        if ([jsonDict objectForKey:@"place"]){
            self.place = [[[Place alloc] initFromJsonDict:[jsonDict objectForKey:@"place"]]autorelease];
            
        }
        
        if ([jsonDict objectForKey:@"user"]){
            self.user = [[[User alloc] initFromJsonDict:[jsonDict objectForKey:@"user"]]autorelease];
        }
        
        [self updateFromJsonDict:jsonDict];
	}
	return self;
}

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    //self.tags = [jsonDict objectForKey:@"tags"];
    self.perspectiveId = [jsonDict objectForKey:@"_id"];
    self.notes = [jsonDict objectForKey:@"memo"];
    self.starred = [[jsonDict objectForKey:@"starred"] boolValue];
    self.lastModified =[jsonDict objectForKey:@"updated_at"];
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
    [lastModified release];
    [super dealloc];
}

@end
