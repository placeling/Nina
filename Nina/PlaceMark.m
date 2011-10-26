//
//  PlaceMark.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceMark.h"

@implementation PlaceMark

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize place=_place;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	DLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(id)initWithPlace:(Place *)place{
    if(self = [super init]){
        self.title = place.name;
        if (place.tags != (id)[NSNull null] || [place.tags count] > 0) {
            // Hack: original API call didn't return # before tags
            // so have to check each entry to see if has #
            NSMutableArray *cleanedTags = [[NSMutableArray alloc] initWithCapacity:[place.tags count]];
            for (int i=0; i < [place.tags count]; i++) {
                NSString *tag = [NSString stringWithFormat:@"%@", [place.tags objectAtIndex:i]];
                if ([tag hasPrefix:@"#"]) {
                    [cleanedTags insertObject:tag atIndex:i];
                } else {
                    [cleanedTags insertObject:[NSString stringWithFormat:@"#%@", tag] atIndex:i];
                }
            }
            self.subtitle = [cleanedTags componentsJoinedByString:@", "];
            
            //self.subtitle = [place.tags componentsJoinedByString:@", "];
        }
        //self.subtitle = place.address;
        coordinate = place.location.coordinate;
        self.place = place;
    }
    return self;
}


-(void)dealloc{
    [title release];
    [subtitle release];
    [_place release];
    [super dealloc];
}

@end
