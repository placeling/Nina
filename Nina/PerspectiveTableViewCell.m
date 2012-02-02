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


@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, savedIndicator, memoText,titleLabel, scrollView;
@synthesize tapGesture, requestDelegate, showMoreButton, shareSheetButton;
@synthesize createdAtLabel, expanded, indexpath;


+(CGFloat) cellHeightUnboundedForPerspective:(Perspective*)perspective{
    CGFloat heightCalc = 59; //covers header and footer
    
    CGSize textAreaSize;
    textAreaSize.height = 600;
    textAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height + 10;
    
    if (perspective.url ){
        heightCalc += 27;
    }
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 160;
    }
    
    return heightCalc;    
}


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 59; //covers header and footer
    
    CGSize textAreaSize;
    textAreaSize.height = 140;
    textAreaSize.width = 233;
    
    
    CGSize maxAreaSize;
    maxAreaSize.height = 600;
    maxAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGSize maxTextSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maxAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height + 10;
    
    if (perspective.url || maxTextSize.height > textSize.height ){
        heightCalc += 18;
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
            memoSize.height = 1000;
            textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:memoSize lineBreakMode:UILineBreakModeWordWrap];
        }
        [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, textSize.width, textSize.height + 10)];
        
        verticalCursor += cell.memoText.frame.size.height;
        hasContent = true;
    }else{
        cell.memoText.text = @""; //get rid of hipster lorem
        cell.memoText.hidden = TRUE;
        verticalCursor += 10;
    }
    
    CGSize textAreaSize;
    textAreaSize.height = 1000;
    textAreaSize.width = 233;
    
    CGSize tempSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    if (tempSize.height > cell.memoText.bounds.size.height) {
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
    
    [cell.userImage  setImageWithURL:[NSURL URLWithString:perspective.user.profilePic.thumbUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
    
    cell.userImage.layer.cornerRadius = 2.0f;
    cell.userImage.layer.borderWidth = 1.0f;
    cell.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
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
    
    if ( !hasContent ){
        //can't star own perspective
        [cell.shareSheetButton setHidden:true];
        [cell.savedIndicator setHidden:true];
    } else {
        [cell.shareSheetButton setHidden:false];
        [cell.savedIndicator setHidden:false];
        if(perspective.starred){            
            [cell.savedIndicator setImage:[UIImage imageNamed:@"ReMark.png"]];
        } else {
            [cell.savedIndicator setImage:[UIImage imageNamed:@"UnReMark.png"]];
        }
    }
    
    cell.createdAtLabel.text = [NSString stringWithFormat:@"last modified: %@", [NinaHelper dateDiff:perspective.lastModified]  ];
    
    [cell.createdAtLabel setFrame:CGRectMake(cell.createdAtLabel.frame.origin.x, verticalCursor, cell.createdAtLabel.frame.size.width, cell.createdAtLabel.frame.size.height)];
    
    [cell.savedIndicator setFrame:CGRectMake(cell.savedIndicator.frame.origin.x, verticalCursor, cell.savedIndicator.frame.size.width, cell.savedIndicator.frame.size.height)];
    
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
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 778;        
        [baseAlert show];
        [baseAlert release];
    } else {
        UIActionSheet *actionSheet;
        
        if ( self.perspective.mine ){
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Share by Email", @"Share on Facebook", nil];
        } else if (self.perspective.starred){
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Share by Email", @"Share on Facebook", @"Remove from My Map", nil];
        } else {
            actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag" otherButtonTitles:@"Share by Email", @"Share on Facebook", @"Add to My Map", nil];
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
        
        // Call url to get profile details                
        RKObjectManager* objectManager = [RKObjectManager sharedManager];       
        [objectManager postObject:nil delegate:self.requestDelegate block:^(RKObjectLoader* loader) {  
            loader.resourcePath = urlText;
            loader.userData = [NSNumber numberWithInt:7]; //use as a tag
        }];
        
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
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NinaHelper getFacebookAppId], @"app_id",
                                       urlString, @"link",
                                       [NSString stringWithFormat:@"%@'s Placemark on %@", perspective.user.username, perspective.place.name], @"caption",
                                       self.perspective.thumbUrl, @"picture",
                                       [NSString stringWithFormat:@"%@'s on Placeling", self.perspective.place.name], @"name",
                                       self.perspective.notes, @"description",
                                       nil];
        
        [facebook dialog:@"feed" andParams:params andDelegate:self.requestDelegate];
         
    } else if (buttonIndex == 3) {
        DLog(@"Add perspective to my map");
        
        // Call url to get profile details                
        RKObjectManager* objectManager = [RKObjectManager sharedManager];       
        
        if (self.perspective.starred){
            [self.perspective unstar];
            [objectManager postObject:nil delegate:self.requestDelegate block:^(RKObjectLoader* loader) {  
                loader.resourcePath = [NSString stringWithFormat:@"/v1/perspectives/%@/unstar", self.perspective.perspectiveId];
                loader.userData = [NSNumber numberWithInt:5]; //use as a tag
            }];
            [self.savedIndicator setImage:[UIImage imageNamed:@"UnReMark.png"]];
        } else {            
            [self.perspective star];
            [objectManager postObject:nil delegate:self.requestDelegate block:^(RKObjectLoader* loader) {  
                loader.resourcePath = [NSString stringWithFormat:@"/v1/perspectives/%@/star", self.perspective.perspectiveId];
                loader.userData = [NSNumber numberWithInt:5]; //use as a tag
            }];
            [self.savedIndicator setImage:[UIImage imageNamed:@"ReMark.png"]];
        }
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
    [savedIndicator release];
    [createdAtLabel release];
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
