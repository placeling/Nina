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

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, upvoteButton, memoText,titleLabel, scrollView;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 39;
    
    CGSize textAreaSize;
    textAreaSize.height = 130;
    textAreaSize.width = 260;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height;
    
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
    }
    
    //cell.memoText.backgroundColor = [UIColor grayColor];
    CGRect memoFrame = cell.memoText.frame;
    CGSize memoSize = memoFrame.size;
        
    if(perspective.notes && perspective.notes.length > 0){
        cell.memoText.text = perspective.notes;
        
        CGSize textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:memoFrame.size lineBreakMode:UILineBreakModeWordWrap];
                
        [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoSize.width, MAX(textSize.height, 44))];
        
        verticalCursor += MAX(textSize.height, 44);
    }else{
        cell.memoText.text = @""; //get rid of hipster lorem
        cell.memoText.hidden = TRUE;
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
    
    cell.userImage.layer.cornerRadius = 8.0f;
    cell.userImage.layer.borderWidth = 1.0f;
    cell.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.userImage.layer.masksToBounds = YES;
    
    if(perspective.photos && perspective.photos.count > 0){
        CGRect scrollFrame = cell.scrollView.frame;
        
        [cell.scrollView setFrame:CGRectMake(scrollFrame.origin.x, verticalCursor, scrollFrame.size.width, 160)];
        
        [cell.scrollView setCanCancelContentTouches:NO];
        
        cell.scrollView.showsHorizontalScrollIndicator = NO;
        cell.scrollView.clipsToBounds = NO;
        cell.scrollView.scrollEnabled = YES;
        cell.scrollView.pagingEnabled = YES;
        
        CGFloat cx = 5;
        for ( Photo* photo in perspective.photos ){
            
            CGRect rect = CGRectMake(cx, 3, 150, 150);
            UIImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [(AsyncImageView*)imageView loadImageFromPhoto:photo]; 
            
            [cell.scrollView addSubview:imageView];
            
            cx += imageView.frame.size.width+5;
            
            [imageView release];
        }
        
        [cell.scrollView setContentSize:CGSizeMake(cx, [cell.scrollView bounds].size.height)];
    }else{
        cell.scrollView.hidden = TRUE; //remove from view
    }
    
    
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
    
    [request setCompletionBlock:^{
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        DLog(@"error on star operation: %@", error);
    }];
    
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
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
