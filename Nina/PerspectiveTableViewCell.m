//
//  PerspectiveTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveTableViewCell.h"

@implementation PerspectiveTableViewCell

@synthesize perspective, userImage, upvoteButton, memoText,titleLabel;


+(CGFloat) cellHeightForPerspective:(Perspective*)perspective{    
    CGFloat heightCalc = 39;
    
    CGSize textAreaSize;
    textAreaSize.height = 130;
    textAreaSize.width = 260;
    
    CGSize textSize = [perspective.notes sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    heightCalc += textSize.height;
    
    return MAX(90, heightCalc);
    
}


+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective userSource:(BOOL)userSource{
    
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
    
    CGSize textSize = [perspective.notes sizeWithFont:cell.memoText.font constrainedToSize:memoSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    [cell.memoText setFrame:CGRectMake(memoFrame.origin.x, memoFrame.origin.y, memoSize.width, MAX(textSize.height, 44))];


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
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
