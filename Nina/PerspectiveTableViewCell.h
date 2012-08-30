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
#import <MessageUI/MFMailComposeViewController.h>
#import <RestKit/RestKit.h>
#import "Facebook.h"
#import "FollowViewController.h"
#import "PerspectiveDisplayProtocol.h"

@interface PerspectiveTableViewCell : UITableViewCell<UIActionSheetDelegate>{
    Perspective *perspective;
    UITapGestureRecognizer *tapGesture;
    UITapGestureRecognizer *likeTapGesture;
    
    UIImageView *userImage;
    
    UIButton *loveButton;
    UIButton *shareSheetButton;
    UIButton *showCommentsButton;
    
    UILabel *memoText;
    UILabel *titleLabel;
    UILabel *createdAtLabel;
    
    UIViewController<RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate, PerspectiveDisplayProtocol> *requestDelegate;
    UIScrollView *scrollView;
    
    UIView *socialFooter;
    
    UIButton *highlightButton;
    UIButton *showMoreButton;    
    UIButton *modifyNotesButton;
    
    NSIndexPath *indexpath;
    
    bool expanded;
    bool myPerspectiveView;
    
    UIView *likeFooter;
    UILabel *likersLabel;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,assign) UIViewController<RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate,PerspectiveDisplayProtocol> *requestDelegate;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UIButton *shareSheetButton;
@property(nonatomic,retain) IBOutlet UILabel *memoText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UIButton *showMoreButton;
@property(nonatomic,retain) IBOutlet UIButton *loveButton;

@property(nonatomic,retain) IBOutlet UIButton *highlightButton;
@property(nonatomic,retain) IBOutlet UIButton *showCommentsButton;

@property(nonatomic,retain) IBOutlet UIButton *modifyNotesButton;

@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;

@property(nonatomic,retain) IBOutlet UIView *socialFooter;
@property(nonatomic,retain) IBOutlet UIView *likeFooter;
@property(nonatomic,retain) IBOutlet UILabel *likersLabel;

@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic,retain) UITapGestureRecognizer *likeTapGesture;
@property(nonatomic,retain) IBOutlet UILabel *createdAtLabel;
@property(nonatomic,retain) NSIndexPath *indexpath;
@property(nonatomic, assign) bool expanded;

@property(nonatomic, assign) bool myPerspectiveView;

-(IBAction)showActionSheet;
-(IBAction)toggleFavourite:(id)sender;
-(IBAction)toggleHighlight:(id)sender;
    
-(IBAction)expandCell;
-(IBAction)onWeb;

//for calculating heights
+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(CGFloat) cellHeightUnboundedForPerspective:(Perspective*)perspective;
+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective  userSource:(BOOL)userSource;

-(IBAction) showAuthoringUser;

-(IBAction) showLikers;
-(IBAction) showComments;


@end
