//
//  MyPerspectiveCellViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyPerspectiveCellViewController.h"
#import "EditPerspectiveViewController.h"

@implementation MyPerspectiveCellViewController

@synthesize imageScroll, footerView;
@synthesize memoLabel, editPromptLabel;
@synthesize perspective=_perspective;
@synthesize footerLabel,modifyPicsButton,modifyNotesButton;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 55; //mostly for footer label
    
    CGSize textAreaSize;
    textAreaSize.height = 66;
    textAreaSize.width = 320;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height;
    
    return heightCalc+10;
    
}


+(void) setupCell:(MyPerspectiveCellViewController*)cell forPerspective:(Perspective*)perspective{
    
    CGFloat verticalCursor = 0;
    cell.perspective = perspective;
    BOOL emptyPerspective = true;
    cell.footerLabel.text = [NSString stringWithFormat:@"Last Modified: %@", perspective.lastModified];
    
    CGRect memoFrame = cell.memoLabel.frame;
    CGSize memoSize = memoFrame.size;
    
    if(perspective.notes || perspective.notes.length > 0){
        emptyPerspective = false;
        cell.memoLabel.text = perspective.notes;
        
        CGSize textSize = [perspective.notes sizeWithFont:cell.memoLabel.font constrainedToSize:memoSize lineBreakMode:UILineBreakModeWordWrap];
        
        [cell.memoLabel setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoSize.width, textSize.height)];

        verticalCursor = cell.memoLabel.frame.size.height;
    }else{
        cell.memoLabel.text = @""; //get rid of hipster lorem
    }
    
    if(emptyPerspective){
        cell.editPromptLabel.text = @"click to add a notes or photos";
        cell.editPromptLabel.hidden = false;
    }
    
    [cell.footerView setFrame:CGRectMake(0, verticalCursor, cell.footerView.frame.size.width, cell.footerView.frame.size.height)];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [_perspective release];
    [memoLabel release];
    [imageScroll release];
    [footerLabel release];
    [modifyPicsButton release];
    [modifyNotesButton release];
    
    [super dealloc];
}

@end
