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

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	DLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(void)dealloc{
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
