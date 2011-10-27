//
//  PerspectiveTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "asyncimageview.h"
#import "MemberProfileViewController.h"
#import "LoginController.h"

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, upvoteButton, memoText,titleLabel, scrollView;
@synthesize tapGesture, requestDelegate, showMoreLabel, showMoreTap;
@synthesize flagTap, flagLabel, createdAtLabel;

+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 59; //covers header and footer
    
    CGSize textAreaSize;
    textAreaSize.height = 100;
    textAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height + 10;
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 166;
    }
    
    return heightCalc;
}


+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective userSource:(BOOL)userSource{
    CGFloat verticalCursor = cell.memoText.frame.origin.y;;
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
    CGSize memoSize = memoFrame.size;
        
    if(perspective.notes && perspective.notes.length > 0){
        cell.memoText.text = perspective.notes;
        
        CGSize textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:memoFrame.size lineBreakMode:UILineBreakModeWordWrap];
                
        [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoSize.width, textSize.height + 10)];
        
        verticalCursor += cell.memoText.frame.size.height;
        hasContent = true;
    }else{
        cell.memoText.text = @""; //get rid of hipster lorem
        cell.memoText.hidden = TRUE;
        verticalCursor += 10;
    }

    if (perspective.mine){
        //can't star own perspective
        [cell.upvoteButton setHidden:true];
    } else {
        [cell.upvoteButton setHidden:false];
        if(perspective.starred){
            [cell.upvoteButton setImage:[UIImage imageNamed:@"starred.png"] forState:UIControlStateNormal];
        } else {
            [cell.upvoteButton setImage:[UIImage imageNamed:@"unstarred.png"] forState:UIControlStateNormal];
        }
    }
    
    cell.userImage.photo = perspective.user.profilePic;
    [cell.userImage loadImage];
    
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
        
        CGFloat cx = cell.memoText.frame.origin.x;
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
    
    if (hasContent && perspective.mine == false){
        cell.flagTap = [[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(flagPerspective)] autorelease];
        [cell.flagLabel addGestureRecognizer:cell.flagTap];
        cell.flagLabel.userInteractionEnabled = TRUE;
        
        [cell.flagLabel setFrame:CGRectMake(cell.flagLabel.frame.origin.x, verticalCursor, cell.flagLabel.frame.size.width, cell.flagLabel.frame.size.height)];
    } else {
        cell.flagLabel.hidden = TRUE;
    }
    cell.createdAtLabel.text = [NSString stringWithFormat:@"Last Modified: %@", [NinaHelper dateDiff:perspective.lastModified]  ];
    
    [cell.createdAtLabel setFrame:CGRectMake(cell.createdAtLabel.frame.origin.x, verticalCursor, cell.createdAtLabel.frame.size.width, cell.createdAtLabel.frame.size.height)];
    
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

-(void) flagPerspective{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Note" 
          message:[NSString stringWithFormat: @"Are you sure you want to flag %@'s note?", self.perspective.user.username] 
          delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 778) {
        if (buttonIndex == 1) {
            LoginController *loginController = [[LoginController alloc] init];
            
            UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
            
            id nextResponder = [self nextResponder];
            while (nextResponder != nil){
                if ([nextResponder isKindOfClass:[UIViewController class]]) {
                    [[(UIViewController*)nextResponder navigationController] presentModalViewController:navBar animated:YES];
                }
                nextResponder = [nextResponder nextResponder];
            }
            
            
            
            //[self.navigationController presentModalViewController:navBar animated:YES];
            [navBar release];
            [loginController release];
        }
    } else {
        if (buttonIndex == 0){
            DLog(@"Cancel flaggin");
        } else {
            DLog(@"Flagging %@'s perspective", self.perspective.user.username);
            
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/flag", [NinaHelper getHostname], self.perspective.perspectiveId];
            self.flagLabel.userInteractionEnabled = FALSE;
            self.flagLabel.textColor = [UIColor blackColor];
            self.flagLabel.text = @"Flagged";
            
            NSURL *url = [NSURL URLWithString:urlText];
            
            ASIFormDataRequest  *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
            
            request.delegate = self.requestDelegate;
            request.tag = 7;
            
            [request setRequestMethod:@"POST"];
            [NinaHelper signRequest:request];
            [request startAsynchronous];
        }
    }
}

-(IBAction)toggleStarred{
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if (currentUser == (id)[NSNull null] || currentUser.length == 0) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in and you can star people's notes & photos";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 778;        
        [baseAlert show];
        [baseAlert release];
    } else {
        NSString *urlText;
        
        if (self.perspective.starred){
            urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/unstar", [NinaHelper getHostname], self.perspective.perspectiveId];
            [self.upvoteButton setImage:[UIImage imageNamed:@"unstarred.png"] forState:UIControlStateNormal];
            self.perspective.starred = false;
        } else {
            urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/star", [NinaHelper getHostname], self.perspective.perspectiveId];
            [self.upvoteButton setImage:[UIImage imageNamed:@"starred.png"] forState:UIControlStateNormal];
            self.perspective.starred = true;
        }
        
        NSURL *url = [NSURL URLWithString:urlText];
        
        ASIFormDataRequest  *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
        
        request.delegate = self.requestDelegate;
        request.tag = 5;
        
        [request setRequestMethod:@"POST"];
        [NinaHelper signRequest:request];
        [request startAsynchronous];
    }
}

-(void) dealloc{
    [perspective release];
    [userImage release];
    [upvoteButton release];
    [memoText release];
    [titleLabel release];
    [scrollView release];
    [tapGesture release];
    
    [flagTap release];
    [flagLabel release];
    [createdAtLabel release];
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
