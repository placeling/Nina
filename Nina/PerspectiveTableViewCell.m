//
//  PerspectiveTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveTableViewCell.h"

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, upvoteButton, memoText;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 10;
    
    CGSize textAreaSize;
    textAreaSize.height = 130;
    textAreaSize.width = 260;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height;
    
    return MAX(90, heightCalc);
    
}


+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective{
    
    cell.perspective = perspective;
    cell.memoText.text = perspective.notes;
    
    //cell.memoText.backgroundColor = [UIColor grayColor];
    
    CGRect memoFrame = cell.memoText.frame;
    CGSize memoSize = memoFrame.size;
    
    CGSize textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:memoSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoSize.width, MAX(textSize.height, 44))];
    
    
}


-(void) dealloc{
    [perspective release];
    [userImage release];
    [upvoteButton release];
    [memoText release];
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
