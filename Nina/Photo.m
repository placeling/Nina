//
//  photo.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Photo.h"


@implementation Photo
@synthesize image, url;

- (void)dealloc
{
    [image release];
    [url release];
    
    [super dealloc];
}

@end
