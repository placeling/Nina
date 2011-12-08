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

@interface PerspectiveTableViewCell : UITableViewCell{
    Perspective *perspective;
    UITapGestureRecognizer *tapGesture;
    UITapGestureRecognizer *showMoreTap;
    UITapGestureRecognizer *flagTap;
    IBOutlet UIImageView *userImage;
    IBOutlet UIButton *upvoteButton;
    IBOutlet UILabel *memoText;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *showMoreLabel;
    IBOutlet UILabel *flagLabel;
    IBOutlet UILabel *createdAtLabel;
    id<ASIHTTPRequestDelegate> requestDelegate;
    IBOutlet UIScrollView *scrollView;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,assign) id<ASIHTTPRequestDelegate> requestDelegate;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UIButton *upvoteButton;
@property(nonatomic,retain) IBOutlet UILabel *memoText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *showMoreLabel;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic,retain) UITapGestureRecognizer *showMoreTap;
@property(nonatomic,retain) UITapGestureRecognizer *flagTap;
@property(nonatomic,retain) IBOutlet UILabel *flagLabel;
@property(nonatomic,retain) IBOutlet UILabel *createdAtLabel;

-(IBAction)toggleStarred;

//for calculating heights
+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective  userSource:(BOOL)userSource;

-(IBAction) showAuthoringUser;
-(void) flagPerspective;

@end
