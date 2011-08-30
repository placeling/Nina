//
//  MyPerspectiveCellViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyPerspectiveCellViewController.h"

@implementation MyPerspectiveCellViewController

@synthesize imageScroll;
@synthesize memoLabel;
@synthesize perspective=_perspective;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [_perspective release];
    [memoLabel release];
    [imageScroll release];
    [super dealloc];
}

@end
