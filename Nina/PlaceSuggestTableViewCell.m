//
//  PlaceSuggestTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceSuggestTableViewCell.h"

@implementation PlaceSuggestTableViewCell

@synthesize imageView, titleLabel, addressLabel, distanceLabel, usersLabel, hilightedView; 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)dealloc{
    [imageView release];
    [titleLabel release];
    [addressLabel release];
    [distanceLabel release];
    [usersLabel release];
    [hilightedView release];
    [super dealloc];
}

@end
