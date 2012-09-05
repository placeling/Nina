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
#import <Twitter/Twitter.h>
#import "CommentViewController.h"
#import "CreateSuggestionViewController.h"


#define hardMaxCellHeight 5000

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, memoText,titleLabel, scrollView;
@synthesize tapGesture, requestDelegate, showMoreButton, loveButton, shareSheetButton;
@synthesize createdAtLabel, expanded, indexpath, likeFooter, likersLabel, likeTapGesture;
@synthesize  showCommentsButton, modifyNotesButton, socialFooter, highlightButton, myPerspectiveView;


+(CGFloat) cellHeightUnboundedForPerspective:(Perspective*)perspective{
    CGFloat heightCalc = 36; //covers title until notes start
    
    CGSize textAreaSize;
    textAreaSize.height = hardMaxCellHeight;
    textAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    if ( perspective.notes &&  [perspective.notes length] > 0 ){
        heightCalc += MAX(textSize.height+3, 10);
    } else {
        heightCalc += 10;
    }
    
    if (perspective.url ){
        heightCalc += 17;
    }
    
    if ( perspective.likers && [perspective.likers count] > 0 ) {
        heightCalc += 24 + 3;
    }
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 160;
    }
    
    if ( ( perspective.notes &&  [perspective.notes length] > 0 ) || [perspective.photos count] > 0 ){
        heightCalc += 50 + 3;
    } 
    
    return MAX(heightCalc, 68); //clear the highlight button if nothign else
}


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 36;

    CGSize textAreaSize;
    textAreaSize.height = 140;
    textAreaSize.width = 233;
    
    
    CGSize maxAreaSize;
    maxAreaSize.height = hardMaxCellHeight;
    maxAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGSize maxTextSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maxAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += MAX(textSize.height+3, 10);
    
    if (perspective.url){ // || maxTextSize.height > textSize.height ){
        heightCalc += 17; //I dont' actually have a good reason for commetnign this out
    }
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 160;
    }
    
    if ( perspective.likers && [perspective.likers count] > 0 ) {
        heightCalc += 24+3;
    }
    
    if ( ( perspective.notes &&  [perspective.notes length] > 0 ) || [perspective.photos count] > 0 ){
        heightCalc += 50 + 3;
    }
    
    
    return MAX(heightCalc, 68); //clear the highlight button if nothign else
}


+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective userSource:(BOOL)userSource{
    CGFloat verticalCursor = cell.titleLabel.frame.origin.y + cell.titleLabel.frame.size.height +3;
    cell.perspective = perspective;
    cell.memoText.text = perspective.notes;
    
    cell.createdAtLabel.text = [NinaHelper dateDiff:perspective.lastModified];
    BOOL hasContent = FALSE;
    
    cell.likeTapGesture =[[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(showLikers)] autorelease];
    cell.likeFooter.userInteractionEnabled = true;
    [cell.likeFooter addGestureRecognizer:cell.likeTapGesture];
    
    cell.socialFooter.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"FooterContainer2.png"]];
    
    cell.showCommentsButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    
    if ([perspective.commentCount intValue]> 0){
        [cell.showCommentsButton setTitle:[perspective.commentCount stringValue] forState:UIControlStateNormal];
    }
    
    if (cell.indexpath.row != 0){
        UIImageView *dividerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
        //verticalCursor += 3;
        [dividerView setImage:[UIImage imageNamed:@"horizontalDivider.png"]];
        [cell addSubview:dividerView];
        [dividerView release];
    }
    
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
            textSize.height = MAX(textSize.height, 10);
        } 
        
        [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, verticalCursor, textSize.width, textSize.height)];
        
        verticalCursor += cell.memoText.frame.size.height + 3;
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
        [cell.showMoreButton setFrame:CGRectMake(cell.showMoreButton.frame.origin.x, verticalCursor, cell.showMoreButton.frame.size.width , cell.showMoreButton.frame.size.height)];
        verticalCursor += cell.showMoreButton.frame.size.height;
        cell.showMoreButton.hidden = false;
    } else if (perspective.url){
        cell.showMoreButton.hidden = false;
        [cell.showMoreButton setTitle:@"More on Web" forState:UIControlStateNormal];
        [cell.showMoreButton setFrame:CGRectMake(cell.showMoreButton.frame.origin.x, verticalCursor, cell.showMoreButton.frame.size.width , cell.showMoreButton.frame.size.height)];
        [cell.showMoreButton addTarget:cell action:@selector(onWeb) forControlEvents:UIControlEventTouchUpInside];
        verticalCursor += cell.showMoreButton.frame.size.height;
        
    } else {
        cell.showMoreButton.hidden = true;
        cell.expanded = true;
    }
    
    if ( ( [cell.requestDelegate isKindOfClass:[MemberProfileViewController class]] && perspective.mine) || cell.myPerspectiveView ){
        //profile or my perspective view, don't show images
        cell.userImage.hidden = true;
        [cell.highlightButton setFrame:CGRectMake(cell.highlightButton.frame.origin.x, 16, cell.highlightButton.frame.size.width, cell.highlightButton.frame.size.height)];
        [cell.modifyNotesButton setFrame:CGRectMake(cell.modifyNotesButton.frame.origin.x, 58, cell.modifyNotesButton.frame.size.width, cell.modifyNotesButton.frame.size.height)];
    } else { 
        cell.userImage.hidden = false; 
        [cell.highlightButton setFrame:CGRectMake(cell.highlightButton.frame.origin.x, 64, cell.highlightButton.frame.size.width, cell.highlightButton.frame.size.height)];
    }
    
    [cell.userImage  setImageWithURL:[NSURL URLWithString:perspective.user.profilePic.thumbUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserPhoto.png"]];
    
    [cell.userImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [cell.userImage.layer setBorderWidth: 2.0];
    cell.userImage.layer.masksToBounds = YES;
    cell.memoText.backgroundColor = [UIColor clearColor];
    
    if(perspective.photos && perspective.photos.count > 0){
        CGRect scrollFrame = cell.scrollView.frame;
        
        if (perspective.photos.count == 1) {//special case where it isn't actually wide enough
            [cell.scrollView setFrame:CGRectMake(scrollFrame.origin.x, verticalCursor,160 , 160)];
        } else {
            [cell.scrollView setFrame:CGRectMake(scrollFrame.origin.x, verticalCursor, scrollFrame.size.width, 160)];
        }
        
        [cell.scrollView setCanCancelContentTouches:NO];
        
        cell.scrollView.showsHorizontalScrollIndicator = NO;
        cell.scrollView.clipsToBounds = NO;
        cell.scrollView.scrollEnabled = YES;
        cell.scrollView.pagingEnabled = YES;
        
        CGFloat cx = 0; //cell.memoText.frame.origin.x;
        for ( Photo* photo in [perspective.photos reverseObjectEnumerator] ){
            
            CGRect rect = CGRectMake(cx, 3, 152, 152);
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            photo.perspective = cell.perspective;
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
    
    if ( !hasContent ){
        //can't star own perspective
        [cell.socialFooter setHidden:true];
    } else {
        [cell.socialFooter setHidden:false];
    }
    
    if ( [perspective.likers count] > 0){
        [cell.likeFooter setHidden:false];
        [cell.likersLabel setText:perspective.likersText];
        [cell.likeFooter setFrame:CGRectMake(cell.likeFooter.frame.origin.x, verticalCursor+3, cell.likeFooter.frame.size.width , cell.likeFooter.frame.size.height)];
        verticalCursor += cell.likeFooter.frame.size.height+3;
    } else {
        [cell.likeFooter setHidden:true];
    }
    
    if ( perspective.mine ){
        if ( cell.myPerspectiveView ){
            cell.modifyNotesButton.hidden = false;
        } else {
            cell.modifyNotesButton.hidden = true;
        }
        [cell.highlightButton setHidden:false];
        
        if (perspective.place && perspective.place.highlighted ){
            [cell.highlightButton setImage:[UIImage imageNamed:@"SelectedButton.png"] forState:UIControlStateNormal];
        } else {
            [cell.highlightButton setImage:[UIImage imageNamed:@"unselectedButton.png"] forState:UIControlStateNormal];
        }
    } else {
        [cell.modifyNotesButton setHidden:true];
        [cell.highlightButton setHidden:true];
        
        if(perspective.starred){
            [cell.loveButton setImage:[UIImage imageNamed:@"LikedFooterButton.png"] forState:UIControlStateNormal];
        } else {
            [cell.loveButton setImage:[UIImage imageNamed:@"LikeButton_Static.png"] forState:UIControlStateNormal];
        }
    }
    
    [cell.socialFooter setFrame:CGRectMake(cell.socialFooter.frame.origin.x, verticalCursor +1, cell.socialFooter.frame.size.width, cell.socialFooter.frame.size.height)];
    //verticalCursor += cell.socialFooter.frame.size.height;
    
    [StyleHelper colourTextLabel:cell.createdAtLabel];
    [StyleHelper colourTextLabel:cell.titleLabel];
    [StyleHelper colourTextLabel:cell.memoText];
    [StyleHelper colourTextLabel:cell.likersLabel];
    
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

#pragma mark - actions

-(IBAction) showLikers{
    
    if ([self.perspective.likers count] > 0){
        FollowViewController *followViewController = [[FollowViewController alloc] initWithPerspective:self.perspective];
        [self.requestDelegate.navigationController pushViewController:followViewController animated:YES];
        [followViewController release];
    }
}

-(IBAction) showComments{
    CommentViewController *commentViewController = [[CommentViewController alloc] init];
    commentViewController.perspective = self.perspective;
    [self.requestDelegate.navigationController pushViewController:commentViewController animated:YES];
    [commentViewController release];
    
}

-(IBAction) showActionSheet{
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser ) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in to share\n or flag this placemark";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self.requestDelegate cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0;        
        [baseAlert show];
        [baseAlert release];
    } else {
        UIActionSheet *actionSheet;
        
        if ([TWTweetComposeViewController canSendTweet]){  
            actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Suggest It", @"Email It", @"Facebook It",  @"Tweet It", nil];
        } else {
            actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Suggest It", @"Email It", @"Facebook It", nil];
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
        DLog(@"Suggest It");
        
        CreateSuggestionViewController *createSuggestionViewController = [[CreateSuggestionViewController alloc] init];
        createSuggestionViewController.place = self.perspective.place;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:createSuggestionViewController];
        [StyleHelper styleNavigationBar:navBar.navigationBar];
        [self.requestDelegate.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        
        [createSuggestionViewController release];
        
    }else if (buttonIndex == 2){
        DLog(@"share member by email");
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self.requestDelegate;
        [controller setSubject:[NSString stringWithFormat:@"%@ on Placeling", self.perspective.place.name]];
        [controller setMessageBody:[NSString stringWithFormat:@"\n\n%@", urlString] isHTML:TRUE];
        
        if (controller) [self.requestDelegate presentModalViewController:controller animated:YES];
        [controller release];	
        
        
    }else if (buttonIndex == 3) {
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
    } else if (buttonIndex == 4){
        DLog(@"share on twitter");        
        
        //Create the tweet sheet
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        
        //Customize the tweet sheet here
        //Add a tweet message
        [tweetSheet setInitialText:[NSString stringWithFormat:@"Check out %@'s placemark on %@ on @placeling",self.perspective.user.username, self.perspective.place.name]];
        
        //Add a link
        //Don't worry, Twitter will handle turning this into a t.co link
        [tweetSheet addURL:[NSURL URLWithString:urlString]];
        
        //Set a blocking handler for the tweet sheet
        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
            [self.requestDelegate dismissModalViewControllerAnimated:YES];
        };
        
        //Show the tweet sheet!
        [self.requestDelegate presentModalViewController:tweetSheet animated:YES];
        [tweetSheet release];
    }
}

-(IBAction)toggleFavourite:(id)sender{
    // Call url to get profile details   
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser ) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in \nto like this placemark";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self.requestDelegate cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0; 
        [baseAlert show];
        [baseAlert release];
        return;
    } 
    
    if (self.perspective.starred){
        [self.perspective unstar];
        
        NSString *urlText = [NSString stringWithFormat:@"/v1/perspectives/%@/unstar", self.perspective.perspectiveId];
        
        [[RKClient sharedClient] post:urlText params:nil delegate:self.requestDelegate]; 
        self.perspective.starred = false;
        [self.loveButton setImage:[UIImage imageNamed:@"LikeButton_Static.png"] forState:UIControlStateNormal];
    } else if (! self.perspective.mine ){
        [self.perspective star];
        NSString *urlText = [NSString stringWithFormat:@"/v1/perspectives/%@/star", self.perspective.perspectiveId];
        [[RKClient sharedClient] post:urlText usingBlock:^(RKRequest *request) {
            request.delegate = self.requestDelegate;
            request.userData = [NSNumber numberWithInt:5]; //use as a tag
        }];
        [self.loveButton setImage:[UIImage imageNamed:@"LikedFooterButton.png"] forState:UIControlStateNormal];
    }
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
    [showCommentsButton release];
    [modifyNotesButton release];
    [socialFooter release];
    [highlightButton release];
    [likeFooter release];
    [likeTapGesture release];
    [likersLabel release];
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
