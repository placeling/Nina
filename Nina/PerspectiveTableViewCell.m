//
//  PerspectiveTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MemberProfileViewController.h"
#import "LoginController.h"
#import "UIImageView+WebCache.h"
#import "asyncimageview.h"
#import "NinaAppDelegate.h"
#import "GenericWebViewController.h"
#import "FlurryAnalytics.h"

#define hardMaxCellHeight 5000

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, memoText,titleLabel, scrollView, remarkersLabel;
@synthesize tapGesture, requestDelegate, showMoreButton, loveButton, shareSheetButton;
@synthesize createdAtLabel, expanded, indexpath;


+(CGFloat) cellHeightUnboundedForPerspective:(Perspective*)perspective{
    CGFloat heightCalc = 65; //covers header and footer
    
    CGSize textAreaSize;
    textAreaSize.height = hardMaxCellHeight;
    textAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    if ( perspective.notes &&  [perspective.notes length] > 0 ){
        heightCalc += MAX(textSize.height, 36);
    } else {
        heightCalc += 10;
    }
    
    if (perspective.url ){
        heightCalc += 17;
    }
    
    if ( perspective.remarkers && [perspective.remarkers length] > 0 ) {
        heightCalc += 17;
    }
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 160;
    }
    
    return heightCalc;    
}


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 65; //covers header and footer
    
    CGSize textAreaSize;
    textAreaSize.height = 140;
    textAreaSize.width = 233;
    
    
    CGSize maxAreaSize;
    maxAreaSize.height = hardMaxCellHeight;
    maxAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGSize maxTextSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maxAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    if ( perspective.notes &&  [perspective.notes length] > 0 ){
        heightCalc += MAX(textSize.height, 36);
    } else {
        heightCalc += 10;
    }
    
    if (perspective.url || maxTextSize.height > textSize.height ){
        heightCalc += 17;
    }
    
    if ( perspective.remarkers && [perspective.remarkers length] > 0 ) {
        heightCalc += 17;
    }
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 160;
    }
    
    return heightCalc;
}


+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective userSource:(BOOL)userSource{
    CGFloat verticalCursor = cell.memoText.frame.origin.y;
    cell.perspective = perspective;
    cell.memoText.text = perspective.notes;
    BOOL hasContent = FALSE;
    
    if (userSource){
        cell.titleLabel.text = perspective.place.name;
    } else {
        cell.titleLabel.text = perspective.user.username;
        cell.titleLabel.userInteractionEnabled = YES;
        cell.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(showAuthoringUser)] autorelease];
        [cell.titleLabel addGestureRecognizer:cell.tapGesture];
    }


    //cell.memoText.backgroundColor = [UIColor grayColor];
    CGRect memoFrame = cell.memoText.frame;
    CGSize memoSize;
    memoSize.width = 233;
    memoSize.height = 140;
        
    if(perspective.notes && perspective.notes.length > 0){
        cell.memoText.text = perspective.notes;
        
        CGSize textSize;
        
        if (!cell.expanded){
            textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:cell.memoText.frame.size lineBreakMode:UILineBreakModeWordWrap];
        } else {
            memoSize.height = hardMaxCellHeight;
            textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:memoSize lineBreakMode:UILineBreakModeWordWrap];
        }
        if ( [perspective.notes length] > 0 ){
            textSize.height = MAX(textSize.height, 36);
        } 
        
        [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, textSize.width, textSize.height)];
        
        verticalCursor += cell.memoText.frame.size.height;
        hasContent = true;
    }else{
        cell.memoText.text = @""; //get rid of hipster lorem
        cell.memoText.hidden = TRUE;
        verticalCursor += 10;
    }
    
    CGSize textAreaSize;
    textAreaSize.height = hardMaxCellHeight;
    textAreaSize.width = 233;
    
    CGSize tempSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    if (tempSize.height > cell.memoText.frame.size.height) {
        cell.expanded = false;
        verticalCursor += 5;
        [cell.showMoreButton setFrame:CGRectMake(cell.showMoreButton.frame.origin.x, verticalCursor, cell.showMoreButton.frame.size.width , cell.showMoreButton.frame.size.height)];
        verticalCursor += cell.showMoreButton.frame.size.height + 5;
        cell.showMoreButton.hidden = false;
    } else if (perspective.url){
        cell.showMoreButton.hidden = false;
        verticalCursor += 5;
        [cell.showMoreButton setTitle:@"More on Web" forState:UIControlStateNormal];
        [cell.showMoreButton setFrame:CGRectMake(cell.showMoreButton.frame.origin.x, verticalCursor, cell.showMoreButton.frame.size.width , cell.showMoreButton.frame.size.height)];
        [cell.showMoreButton addTarget:cell action:@selector(onWeb) forControlEvents:UIControlEventTouchUpInside];
        verticalCursor += cell.showMoreButton.frame.size.height + 5;
        
    } else {
        cell.showMoreButton.hidden = true;
        cell.expanded = true;
    }
    
    if ( [cell.requestDelegate isKindOfClass:[MemberProfileViewController class]] ){
        //profile view, don't show images
        cell.userImage.hidden = true;
        [cell.loveButton setFrame:CGRectMake(cell.loveButton.frame.origin.x, 16, cell.loveButton.frame.size.width, cell.loveButton.frame.size.height)];
    } else { 
        cell.userImage.hidden = false; 
        [cell.loveButton setFrame:CGRectMake(cell.loveButton.frame.origin.x, 56, cell.loveButton.frame.size.width, cell.loveButton.frame.size.height)];
    }
    
    [cell.userImage  setImageWithURL:[NSURL URLWithString:perspective.user.profilePic.thumbUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
    
    [cell.userImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [cell.userImage.layer setBorderWidth: 2.0];
    cell.userImage.layer.masksToBounds = YES;
    cell.memoText.backgroundColor = [UIColor clearColor];
    
    if(perspective.photos && perspective.photos.count > 0){
        CGRect scrollFrame = cell.scrollView.frame;
        
        [cell.scrollView setFrame:CGRectMake(scrollFrame.origin.x, verticalCursor, scrollFrame.size.width, 160)];
        
        [cell.scrollView setCanCancelContentTouches:NO];
        
        cell.scrollView.showsHorizontalScrollIndicator = NO;
        cell.scrollView.clipsToBounds = NO;
        cell.scrollView.scrollEnabled = YES;
        cell.scrollView.pagingEnabled = YES;
        
        CGFloat cx = 0; //cell.memoText.frame.origin.x;
        for ( Photo* photo in [perspective.photos reverseObjectEnumerator] ){
            
            CGRect rect = CGRectMake(cx, 3, 152, 152);
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [imageView setPhoto:photo]; 
            [imageView loadImageFromPhoto:photo]; 
            imageView.userInteractionEnabled = TRUE;
            [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [imageView.layer setBorderWidth: 5.0];
            [cell.scrollView addSubview:imageView];
            
            cx += imageView.frame.size.width+2;
            
            [imageView release];
        }
        verticalCursor += cell.scrollView.frame.size.height;
        [cell.scrollView setContentSize:CGSizeMake(cx, [cell.scrollView bounds].size.height)];
        
        hasContent = true;
        
    }else{
        cell.scrollView.hidden = TRUE; //remove from view
    }
    
    if ( perspective.remarkers && [perspective.remarkers length] > 0 ) {
        [cell.remarkersLabel setFrame:CGRectMake(cell.remarkersLabel.frame.origin.x, verticalCursor, cell.remarkersLabel.frame.size.width, cell.remarkersLabel.frame.size.height)];
        cell.remarkersLabel.text = [NSString stringWithFormat:@"Liked By: %@", perspective.remarkers  ];
         verticalCursor += cell.remarkersLabel.frame.size.height;
    } else {
        cell.remarkersLabel.hidden = true;
    }
    
    if ( perspective.mine ){
        [cell.loveButton setHidden:false];
        if (perspective.place && perspective.place.highlighted && cell.userImage.hidden){
            [cell.loveButton setImage:[UIImage imageNamed:@"HilightMarker.png"] forState:UIControlStateNormal];
        } else {
            [cell.loveButton setImage:[UIImage imageNamed:@"MyMarker.png"] forState:UIControlStateNormal];
        }
        [cell.loveButton addTarget:cell action:@selector(toggleHighlight:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        if ( !hasContent ){
            //can't star own perspective
            [cell.shareSheetButton setHidden:true];
            [cell.loveButton setHidden:true];
        } else {
            [cell.loveButton addTarget:cell action:@selector(toggleFavourite:) forControlEvents:UIControlEventTouchUpInside];
            [cell.shareSheetButton setHidden:false];
            [cell.loveButton setHidden:false];
            if(perspective.starred){            
                [cell.loveButton setImage:[UIImage imageNamed:@"AddPlace_Hover2.png"] forState:UIControlStateNormal];
            } else {
                [cell.loveButton setImage:[UIImage imageNamed:@"AddPlace_Added.png"] forState:UIControlStateNormal];
            }
        }
    }
    
    cell.createdAtLabel.text = [NSString stringWithFormat:@"Updated: %@", [NinaHelper dateDiff:perspective.lastModified]  ];
    
    [cell.createdAtLabel setFrame:CGRectMake(cell.createdAtLabel.frame.origin.x, verticalCursor, cell.createdAtLabel.frame.size.width, cell.createdAtLabel.frame.size.height)];
    [cell.shareSheetButton setFrame:CGRectMake(cell.shareSheetButton.frame.origin.x, verticalCursor, cell.shareSheetButton.frame.size.width, cell.shareSheetButton.frame.size.height)];
    
    [StyleHelper colourTextLabel:cell.createdAtLabel];
    [StyleHelper colourTextLabel:cell.titleLabel];
    [StyleHelper colourTextLabel:cell.memoText];
    
    cell.accessoryView = nil;
    
    //cell.scrollView.delegate = cell;
}


-(IBAction)expandCell{
    [self.requestDelegate expandAtIndexPath:self.indexpath];    
}

-(IBAction)onWeb{
    GenericWebViewController *webController = [[GenericWebViewController alloc] initWithUrl:perspective.url];
    
    [FlurryAnalytics logEvent:@"ON_WEB_CLICK" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"url", perspective.url, nil]];
    
    [self.requestDelegate.navigationController pushViewController:webController animated:true];
    [webController release];
}


#pragma mark - Share Sheet

-(IBAction) showActionSheet{
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser ) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in to share or flag this placemark";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self.requestDelegate cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0;        
        [baseAlert show];
        [baseAlert release];
    } else {
        UIActionSheet *actionSheet;
        
        if ( self.perspective.mine ){
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Share by Email", @"Share on Facebook", nil];
        } else {
            actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Share by Email", @"Share on Facebook", nil];
        }

        [actionSheet showInView:self.requestDelegate.view];
        [actionSheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *urlString = [NSString stringWithFormat:@"https://www.placeling.com/perspectives/%@", self.perspective.perspectiveId];
     
    if (buttonIndex == 0){
        DLog(@"Flag Perspective");
        
        NSString *urlText = [NSString stringWithFormat:@"/v1/perspectives/%@/flag", self.perspective.perspectiveId];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:self.requestDelegate]; 
        
    }else if (buttonIndex == 1){
        DLog(@"share member by email");
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self.requestDelegate;
        [controller setSubject:[NSString stringWithFormat:@"\"%@\" on Placeling", self.perspective.place.name]];
        [controller setMessageBody:[NSString stringWithFormat:@"\n\n%@", urlString] isHTML:TRUE];
        
        if (controller) [self.requestDelegate presentModalViewController:controller animated:YES];
        [controller release];	
        
        
    }else if (buttonIndex == 2) {
        DLog(@"share on facebook");
        
        NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
        Facebook *facebook = appDelegate.facebook;
        
        if (![facebook isSessionValid]) {
            NSArray* permissions =  [[NSArray arrayWithObjects:
                                      @"email", @"publish_stream",@"offline_access", nil] retain];
            
            [facebook authorize:permissions];
            
            [permissions release];
        } else {            
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NinaHelper getFacebookAppId], @"app_id",
                                           urlString, @"link",
                                           [NSString stringWithFormat:@"%@'s Placemark on %@", perspective.user.username, perspective.place.name], @"caption",
                                           self.perspective.thumbUrl, @"picture",
                                           [NSString stringWithFormat:@"%@'s on Placeling", self.perspective.place.name], @"name",
                                           self.perspective.notes, @"description",
                                           nil];
            
            [facebook dialog:@"feed" andParams:params andDelegate:self.requestDelegate];
        }
    }
}

-(IBAction)toggleFavourite:(id)sender{
    // Call url to get profile details   
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser ) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in to like this placemark";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self.requestDelegate cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0; 
        [baseAlert show];
        [baseAlert release];
        return;
    } 
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];       
    
    if (self.perspective.starred){
        [self.perspective unstar];
        
        NSString *urlText = [NSString stringWithFormat:@"/v1/perspectives/%@/unstar", self.perspective.perspectiveId];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:self.requestDelegate]; 
        self.perspective.starred = false;
        [self.loveButton setImage:[UIImage imageNamed:@"AddPlace_Added.png"] forState:UIControlStateNormal];
    } else {            
        [self.perspective star];
        [objectManager postObject:nil delegate:self.requestDelegate block:^(RKObjectLoader* loader) {  
            loader.resourcePath = [NSString stringWithFormat:@"/v1/perspectives/%@/star", self.perspective.perspectiveId];
            loader.userData = [NSNumber numberWithInt:5]; //use as a tag
        }];
        [self.loveButton setImage:[UIImage imageNamed:@"AddPlace_Hover2.png"] forState:UIControlStateNormal];
    }
}

-(IBAction)toggleHighlight:(id)sender{
    if ( self.perspective.place.highlighted ){
        [sender setImage:[UIImage imageNamed:@"MyMarker.png"] forState:UIControlStateNormal];
        self.perspective.place.highlighted = false;
        NSString *urlText = [NSString stringWithFormat:@"/v1/places/%@/unhighlight", self.perspective.place.pid];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:nil]; 
        
    } else {
        [sender setImage:[UIImage imageNamed:@"HilightMarker.png"] forState:UIControlStateNormal];
        self.perspective.place.highlighted = true;
        NSString *urlText = [NSString stringWithFormat:@"/v1/places/%@/highlight", self.perspective.place.pid];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:nil]; 
    }
}


-(IBAction) showAuthoringUser{
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    
    memberProfileViewController.user = self.perspective.user;
    
    //not a fan of this way, but any other seems to have circular reference issues
    id nextResponder = [self nextResponder];
    while (nextResponder != nil){
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            [[(UIViewController*)nextResponder navigationController] pushViewController:memberProfileViewController animated:TRUE];
        }
        nextResponder = [nextResponder nextResponder];
    }
    
    [memberProfileViewController release];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
    // If not dragging, send event to next responder
    if (!scrollView.dragging) 
        [self.nextResponder touchesEnded: touches withEvent:event]; 
    else
        [super touchesEnded: touches withEvent: event];
}


-(void) dealloc{
    [perspective release];
    [userImage release];
    [shareSheetButton release];
    [memoText release];
    [titleLabel release];
    [scrollView release];
    [tapGesture release];
    [loveButton release];
    [createdAtLabel release];
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
