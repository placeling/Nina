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
#import "GenericWebViewController.h"
#import "FlurryAnalytics.h"
#import "UserManager.h"

@implementation MyPerspectiveCellViewController

@synthesize imageScroll, footerView, requestDelegate;
@synthesize memoLabel, editPromptLabel;
@synthesize perspective=_perspective;
@synthesize footerLabel,modifyPicsButton,modifyNotesButton;
@synthesize showMoreButton, highlightButton;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 87; //mostly for footer label
    
    CGSize textAreaSize;
    textAreaSize.height = 5000;
    textAreaSize.width = 280;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height;

    if ( perspective.photos && perspective.photos.count > 0 ){
        heightCalc += 160;
    }
    
    if ( perspective.url ){
        heightCalc += 17;
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
        memoFrame.size.height = 5000;
        
        CGSize textSize = [perspective.notes sizeWithFont:cell.memoLabel.font constrainedToSize:memoFrame.size lineBreakMode:UILineBreakModeWordWrap];
        
        [cell.memoLabel setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoFrame.size.width, textSize.height)];
        
        verticalCursor += textSize.height;
    }else{
        cell.memoLabel.text = @""; //get rid of hipster lorem
        cell.memoLabel.hidden = TRUE;
    }
    
    if (perspective.url){
        cell.showMoreButton.hidden = false;
        verticalCursor += 5;
        [cell.showMoreButton setTitle:@"More on Web" forState:UIControlStateNormal];
        [cell.showMoreButton setFrame:CGRectMake(cell.showMoreButton.frame.origin.x, verticalCursor, cell.showMoreButton.frame.size.width , cell.showMoreButton.frame.size.height)];
        [cell.showMoreButton addTarget:cell action:@selector(onWeb) forControlEvents:UIControlEventTouchUpInside];
        verticalCursor += cell.showMoreButton.frame.size.height + 5;
    } else {
        cell.showMoreButton.hidden = true; 
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
            photo.mine = true;
            photo.perspective = perspective;
            
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
    
    if ( perspective.place.highlighted ){
        [cell.highlightButton setImage:[UIImage imageNamed:@"SelectedButton.png"] forState:UIControlStateNormal];
    } else {
        [cell.highlightButton setImage:[UIImage imageNamed:@"unselectedButton.png"] forState:UIControlStateNormal];
    }
    [cell.highlightButton addTarget:cell action:@selector(toggleHighlight:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.footerView setFrame:CGRectMake(0, verticalCursor, cell.footerView.frame.size.width, cell.footerView.frame.size.height)];
    
}

-(IBAction)toggleHighlight:(id)sender{
    if ( self.perspective.place.highlighted ){
        [sender setImage:[UIImage imageNamed:@"unselectedButton.png"] forState:UIControlStateNormal];
        self.perspective.place.highlighted = false;
        NSString *urlText = [NSString stringWithFormat:@"/v1/places/%@/unhighlight", self.perspective.place.pid];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:nil]; 
        
    } else {
        [sender setImage:[UIImage imageNamed:@"SelectedButton.png"] forState:UIControlStateNormal];
        self.perspective.place.highlighted = true;
        NSString *urlText = [NSString stringWithFormat:@"/v1/places/%@/highlight", self.perspective.place.pid];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:nil]; 

    }
    [UserManager updatePerspectiveNoOrderChange:self.perspective];
}


-(IBAction)onWeb{
    GenericWebViewController *webController = [[GenericWebViewController alloc] initWithUrl:self.perspective.url];
    
    [FlurryAnalytics logEvent:@"ON_WEB_CLICK" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"url", self.perspective.url, nil]];
    
    [self.requestDelegate.navigationController pushViewController:webController animated:true];
    [webController release];
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
    [showMoreButton release];
    [highlightButton release];
    
    [super dealloc];
}

@end
