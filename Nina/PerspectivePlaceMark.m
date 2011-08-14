//
//  PerspectivePlaceMark.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectivePlaceMark.h"
#import "NinaHelper.h"


@implementation PerspectivePlaceMark

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize perspective;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	DLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(id)initFromPerspective:(Perspective *)newPerspective{
    if(self = [super init]){
        self.title = newPerspective.place.name;
        self.subtitle = newPerspective.place.address;
        coordinate = newPerspective.place.location.coordinate;
        self.perspective = newPerspective;
    }
    return self;
}


-(void)dealloc{
    [title release];
    [subtitle release];
    [perspective release];
    [super dealloc];
}

@end
