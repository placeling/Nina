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
#import "PerspectiveDisplayProtocol.h"

@interface PerspectiveTableViewCell : UITableViewCell<UIActionSheetDelegate>{
    Perspective *perspective;
    UITapGestureRecognizer *tapGesture;
    UIImageView *userImage;
    UIButton *shareSheetButton;
    UILabel *memoText;
    UILabel *titleLabel;
    UILabel *createdAtLabel;
    UILabel *remarkersLabel;
    UIViewController<RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate, PerspectiveDisplayProtocol> *requestDelegate;
    UIScrollView *scrollView;
    
    UIButton *loveButton;
    UIButton *showMoreButton;
    
    NSIndexPath *indexpath;
    
    bool expanded;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,assign) UIViewController<RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate,PerspectiveDisplayProtocol> *requestDelegate;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UIButton *shareSheetButton;
@property(nonatomic,retain) IBOutlet UILabel *memoText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *remarkersLabel;
@property(nonatomic,retain) IBOutlet UIButton *showMoreButton;
@property(nonatomic,retain) IBOutlet UIButton *loveButton;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic,retain) IBOutlet UILabel *createdAtLabel;
@property(nonatomic,retain) NSIndexPath *indexpath;
@property(nonatomic, assign) bool expanded;

-(IBAction)showActionSheet;
-(IBAction)toggleFavourite;
-(IBAction)expandCell;
-(IBAction)onWeb;

//for calculating heights
+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(CGFloat) cellHeightUnboundedForPerspective:(Perspective*)perspective;
+(void) setupCell:(PerspectiveTableViewCell*)cell forPerspective:(Perspective*)perspective  userSource:(BOOL)userSource;

-(IBAction) showAuthoringUser;

@end
