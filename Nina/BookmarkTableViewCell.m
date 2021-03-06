//
//  BookmarkTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarkTableViewCell.h"

@implementation BookmarkTableViewCell

@synthesize place, bookmarkButton;
@synthesize delegate;



-(void) dealloc{
    [place release];
    [bookmarkButton release];
    [super dealloc];
}

-(IBAction) bookmark{
    [self.delegate bookmark];
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
