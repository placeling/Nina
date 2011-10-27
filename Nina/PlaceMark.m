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

        NSMutableArray *cleanedTags = [[NSMutableArray alloc] init];
        for (NSString *tag in place.tags){ 
            if ([tag hasPrefix:@"#"]) {
                [cleanedTags addObject:tag];
            } else {
                [cleanedTags addObject:[NSString stringWithFormat:@"#%@", tag]];
            }
        }
        self.subtitle = [cleanedTags componentsJoinedByString:@", "];
        [cleanedTags release];
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
