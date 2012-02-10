//
//  PlaceDetail.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Perspective.h"
#import "NSDictionary+Utility.h"
#import "Photo.h"

@implementation Perspective
@synthesize user, place, notes, tags, photos, starred, lastModified, remarkers;
@synthesize dateAdded, visited, share, mine, perspectiveId, modified, url;

-(id) initFromJsonDict:(NSDictionary *)jsonDict{
    if(self = [super init]){
        if ([jsonDict objectForKey:@"place"]){
            self.place = [[[Place alloc] initFromJsonDict:[jsonDict objectForKey:@"place"]]autorelease];
            
        }
        
        if ([jsonDict objectForKey:@"user"]){
            //RKObjectManager* objectManager = [RKObjectManager sharedManager];
            //NSManagedObjectContext *managedObjectContext = objectManager.objectStore.managedObjectContext;
            //self.user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
            self.user = [[[User alloc] init] autorelease];
            [self.user updateFromJsonDict:[jsonDict objectForKey:@"user"]];
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
    
    //RKObjectManager* objectManager = [RKObjectManager sharedManager];
    //NSObjectContext *managedObjectContext = objectManager.objectStore.managedObjectContext;
    
    [self.photos removeAllObjects];
    for (NSDictionary *photoDict in [jsonDict objectForKey:@"photos"]){

        //Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:managedObjectContext];  
        
        Photo *newPhoto = [[Photo alloc] init];
        
        [newPhoto updateFromJsonDict:photoDict];
        newPhoto.perspective = self;
        newPhoto.mine = self.mine;
        [self.photos addObject:newPhoto];
        [newPhoto release];
    }    
    
    self.perspectiveId = [jsonDict objectForKeyNotNull:@"_id"];
    self.notes = [jsonDict objectForKeyNotNull:@"memo"];
    self.starred = [[jsonDict objectForKeyNotNull:@"starred"] boolValue];
    self.lastModified =[jsonDict objectForKeyNotNull:@"updated_at"];
    self.url = [jsonDict objectForKeyNotNull:@"url"];    
}


+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* perspectiveMapping = [RKObjectMapping mappingForClass:[Perspective class]];

    [perspectiveMapping mapKeyPathsToAttributes:     
     @"id", @"perspectiveId",
     @"mine", @"mine",
     @"memo", @"notes",     
     @"starred", @"starred",
     @"updated_at", @"lastModified",
     @"url", @"url",
     @"remarkers", @"remarkers",
     nil];
    
    [perspectiveMapping mapKeyPath:@"place" toRelationship:@"place" withMapping:[Place getObjectMappingNoPerspectives]];
    
    [perspectiveMapping mapKeyPath:@"photos" toRelationship:@"photos" withMapping:[Photo getObjectMapping]];
    
    [perspectiveMapping mapKeyPath:@"user" toRelationship:@"user" withMapping:[User getObjectMapping]];
    
    return perspectiveMapping;
}


-(void) star{
    if (self.place){
        self.starred = true;
        self.place.dirty = true;

        [self.place.homePerspectives addObject:self];
        
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
                break;
            }
        }
        
        for (Perspective *p in self.place.followingPerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = false;
                break;
            }
        }
        for (Perspective *p in self.place.everyonePerspectives){
            if ([p.perspectiveId isEqualToString:self.perspectiveId]){
                p.starred = false;
                break;
            }
        }        
    }
}

-(NSString*)thumbUrl{
    if ([[self photos] count] > 0){
        return ((Photo*)[[self photos] objectAtIndex:0]).thumbUrl;
    } else if (self.place) {
        return self.place.placeThumbUrl;
    } else {
        return @"http://www.placeling.com/images/placeling_thumb_logo.png";
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
    [remarkers release];
    [super dealloc];
}

@end
