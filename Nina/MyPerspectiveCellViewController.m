//
//  MyPerspectiveCellViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyPerspectiveCellViewController.h"
#import "EditPerspectiveViewController.h"
#import "asyncimageview.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyPerspectiveCellViewController

@synthesize imageScroll, footerView;
@synthesize memoLabel, editPromptLabel;
@synthesize perspective=_perspective;
@synthesize footerLabel,modifyPicsButton,modifyNotesButton;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 87; //mostly for footer label
    
    CGSize textAreaSize;
    textAreaSize.height = 66;
    textAreaSize.width = 320;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height;

    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 160;
    }
    
    return heightCalc;
}


+(void) setupCell:(MyPerspectiveCellViewController*)cell forPerspective:(Perspective*)perspective{
    
    CGFloat verticalCursor = cell.memoLabel.frame.origin.y;
    cell.perspective = perspective;
    BOOL emptyPerspective = true;
    cell.footerLabel.text = [NSString stringWithFormat:@"last modified: %@", [NinaHelper dateDiff:perspective.lastModified]  ];
    
    if(perspective.notes && perspective.notes.length > 0){
        emptyPerspective = false;
        cell.memoLabel.text = perspective.notes;
        CGRect memoFrame = cell.memoLabel.frame;
        
        CGSize textSize = [perspective.notes sizeWithFont:cell.memoLabel.font constrainedToSize:memoFrame.size lineBreakMode:UILineBreakModeWordWrap];
        
        [cell.memoLabel setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoFrame.size.width, textSize.height)];
        
        verticalCursor += textSize.height;
    }else{
        cell.memoLabel.text = @""; //get rid of hipster lorem
        cell.memoLabel.hidden = TRUE;
    }
    
    if(perspective.photos && perspective.photos.count > 0){
        emptyPerspective = false;
        CGRect scrollFrame = cell.imageScroll.frame;
        [cell.imageScroll setFrame:CGRectMake(scrollFrame.origin.x, verticalCursor, scrollFrame.size.width, scrollFrame.size.height)];
        
        [cell.imageScroll setCanCancelContentTouches:NO];
        
        cell.imageScroll.showsHorizontalScrollIndicator = NO;
        cell.imageScroll.clipsToBounds = NO;
        cell.imageScroll.scrollEnabled = YES;
        cell.imageScroll.pagingEnabled = YES;
        
        CGFloat cx = 5;
        for ( Photo* photo in [perspective.photos reverseObjectEnumerator] ){
            
            CGRect rect = CGRectMake(cx, 3, 150, 150);
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [imageView loadImageFromPhoto:photo]; 
            imageView.userInteractionEnabled = TRUE;
            [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [imageView.layer setBorderWidth: 5.0];   
            [cell.imageScroll addSubview:imageView];
            
            cx += imageView.frame.size.width+5;
            
            [imageView release];
        }
        
        verticalCursor += scrollFrame.size.height;
        [cell.imageScroll setContentSize:CGSizeMake(cx, [cell.imageScroll bounds].size.height)];
    }else{
        cell.imageScroll.hidden = TRUE; //remove from view
    }
    
    if(emptyPerspective){
        cell.editPromptLabel.text = @"tap to add notes or photos";
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
