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

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, upvoteButton, memoText,titleLabel, scrollView;
@synthesize tapGesture, requestDelegate, showMoreLabel, showMoreTap;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 39;
    
    CGSize textAreaSize;
    textAreaSize.height = 100;
    textAreaSize.width = 233;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += MAX(textSize.height, 44);
    
    if (perspective.photos && perspective.photos.count > 0){
        heightCalc += 166;
    }
    
    return MAX(90, heightCalc);
}


+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective userSource:(BOOL)userSource{
    CGFloat verticalCursor = cell.memoText.frame.origin.y;;
    cell.perspective = perspective;
    cell.memoText.text = perspective.notes;
    
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
                
        [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoSize.width, MAX(textSize.height, 55))];
        
        verticalCursor += cell.memoText.frame.size.height;
    }else{
        cell.memoText.text = @""; //get rid of hipster lorem
        cell.memoText.hidden = TRUE;
        verticalCursor += 55;
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
    
    cell.userImage.layer.cornerRadius = 8.0f;
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
        
        CGFloat cx = 2;
        for ( Photo* photo in [perspective.photos reverseObjectEnumerator] ){
            
            CGRect rect = CGRectMake(cx, 3, 152, 152);
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [imageView setPhoto:photo]; 
            [imageView loadImageFromPhoto:photo]; 
            imageView.userInteractionEnabled = TRUE;
            
            [cell.scrollView addSubview:imageView];
            
            cx += imageView.frame.size.width+2;
            
            [imageView release];
        }
        
        //more then 2 photos means a scroll, otherwise click should go to page
        /*
        if ([perspective.photos count] > 2){
            cell.scrollView.userInteractionEnabled = true;
        } else {
            cell.scrollView.userInteractionEnabled = false;
        }*/
        
        [cell.scrollView setContentSize:CGSizeMake(cx, [cell.scrollView bounds].size.height)];
    }else{
        cell.scrollView.hidden = TRUE; //remove from view
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

-(IBAction)toggleStarred{
    
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


-(void) dealloc{
    [perspective release];
    [userImage release];
    [upvoteButton release];
    [memoText release];
    [titleLabel release];
    [scrollView release];
    [tapGesture release];
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
