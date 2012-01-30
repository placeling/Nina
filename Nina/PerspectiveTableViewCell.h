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

@interface PerspectiveTableViewCell : UITableViewCell<UIActionSheetDelegate>{
    Perspective *perspective;
    UITapGestureRecognizer *tapGesture;
    UIImageView *userImage;
    UIImageView *savedIndicator;
    UIButton *shareSheetButton;
    UILabel *memoText;
    UILabel *titleLabel;
    UILabel *createdAtLabel;
    UIViewController<RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate> *requestDelegate;
    UIScrollView *scrollView;
    UIButton *showMoreButton;
    
    bool expanded;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,assign) UIViewController<RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate> *requestDelegate;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UIImageView *savedIndicator;
@property(nonatomic,retain) IBOutlet UIButton *shareSheetButton;
@property(nonatomic,retain) IBOutlet UILabel *memoText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UIButton *showMoreButton;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic,retain) IBOutlet UILabel *createdAtLabel;

@property(nonatomic, assign) bool expanded;

-(IBAction)showActionSheet;
-(IBAction)expandCell;

//for calculating heights
+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(CGFloat) cellHeightUnboundedForPerspective:(Perspective*)perspective;
+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective  userSource:(BOOL)userSource;

-(IBAction) showAuthoringUser;

@end
