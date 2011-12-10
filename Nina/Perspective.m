//
//  PlaceDetail.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Perspective.h"
#import "NSDictionary+Utility.h"


@implementation Perspective
@synthesize user, place, notes, tags, photos, starred, lastModified;
@synthesize dateAdded, visited, share, mine, perspectiveId, modified, url;

-(id) initFromJsonDict:(NSDictionary *)jsonDict{
    if(self = [super init]){
        if ([jsonDict objectForKey:@"place"]){
            self.place = [[[Place alloc] initFromJsonDict:[jsonDict objectForKey:@"place"]]autorelease];
            
        }
        
        if ([jsonDict objectForKey:@"user"]){
            self.user = [[[User alloc] initFromJsonDict:[jsonDict objectForKey:@"user"]]autorelease];
        }
        
        NSMutableArray *initPhotos = [[NSMutableArray alloc] init];
        self.photos = initPhotos;
        [initPhotos release];
        
        [self updateFromJsonDict:jsonDict];
        modified = false;
	}
	return self;
}

-(void) updateFromJsonDict:(NSDictionary *)jsonDict{
    mine = [[jsonDict objectForKey:@"mine"] boolValue];
    
    [self.photos removeAllObjects];
    for (NSDictionary *photoDict in [jsonDict objectForKey:@"photos"]){
        Photo *photo = [[Photo alloc] initFromJsonDict:photoDict];
        photo.perspective = self;
        photo.mine = self.mine;
        [self.photos addObject:photo];
        [photo release];
    }    
    
    self.perspectiveId = [jsonDict objectForKeyNotNull:@"_id"];
    self.notes = [jsonDict objectForKeyNotNull:@"memo"];
    self.starred = [[jsonDict objectForKeyNotNull:@"starred"] boolValue];
    self.lastModified =[jsonDict objectForKeyNotNull:@"updated_at"];
    self.url = [jsonDict objectForKeyNotNull:@"url"];
    
    
}

-(void) star{
    if (self.place){
        self.starred = true;
        self.place.dirty = true;

        for (Perspective *p in self.place.followingPerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = true;
            }
        }
        for (Perspective *p in self.place.everyonePerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = true;
            }
        }        
    }
}

-(void) unstar{
    if (self.place){
        self.starred = false;      
        self.place.dirty = true;

        for (Perspective *p in self.place.homePerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = false;
                [self.place.homePerspectives removeObject:p];
            }
        }
        
        for (Perspective *p in self.place.followingPerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = false;
            }
        }
        for (Perspective *p in self.place.everyonePerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = false;
            }
        }        
    }
}

- (void) dealloc {
    [user release];
    [url release];
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
