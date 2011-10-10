//
//  PerspectiveTableViewCell.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"
#import "NinaHelper.h"
#import "asyncimageview.h"

@interface PerspectiveTableViewCell : UITableViewCell{
    Perspective *perspective;
    UITapGestureRecognizer *tapGesture;
    IBOutlet AsyncImageView *userImage;
    IBOutlet UIButton *upvoteButton;
    IBOutlet UITextView *memoText;
    IBOutlet UILabel *titleLabel;
    id<ASIHTTPRequestDelegate> requestDelegate;
    IBOutlet UIScrollView *scrollView;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,assign) id<ASIHTTPRequestDelegate> requestDelegate;
@property(nonatomic,retain) IBOutlet AsyncImageView *userImage;
@property(nonatomic,retain) IBOutlet UIButton *upvoteButton;
@property(nonatomic,retain) IBOutlet UITextView *memoText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UITapGestureRecognizer *tapGesture;

-(IBAction)toggleStarred;

//for calculating heights
+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective  userSource:(BOOL)userSource;

-(IBAction) showAuthoringUser;

@end
