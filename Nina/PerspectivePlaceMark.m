//
//  PerspectivePlaceMark.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectivePlaceMark.h"


@implementation PerspectivePlaceMark

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize perspective=_perspective;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	DLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(id)initFromPerspective:(Perspective *)perspective{
    if(self = [super init]){
        self.title = perspective.place.name;
        self.subtitle = perspective.place.streetAddress;
        coordinate = perspective.place.location.coordinate;
        self.perspective = perspective;
    }
    return self;
}


-(void)dealloc{
    [title release];
    [subtitle release];
    [_perspective release];
    [super dealloc];
}

@end
