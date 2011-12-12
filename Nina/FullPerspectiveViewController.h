//
//  FullPerspectiveViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"
#import "NinaHelper.h"
#import "LoginController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface FullPerspectiveViewController : UIViewController <LoginControllerDelegate,MFMailComposeViewControllerDelegate, FBDialogDelegate, UIActionSheetDelegate>{
    Perspective *perspective;
    UITapGestureRecognizer *tapGesture;
    UITapGestureRecognizer *flagTap;
    IBOutlet UIImageView *userImage;
    IBOutlet UIButton *upvoteButton;
    IBOutlet UITextView *memoText;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *flagLabel;
    UIButton *moreOnWeb;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UIButton *upvoteButton;
@property(nonatomic,retain) IBOutlet UITextView *memoText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic,retain) UITapGestureRecognizer *flagTap;
@property(nonatomic,retain) IBOutlet UILabel *flagLabel;
@property(nonatomic,retain) IBOutlet UIButton *moreOnWeb;

-(IBAction) toggleStarred;
-(IBAction) showAuthoringUser;
-(IBAction) goToWeb;

-(void) mainContentLoad; // public as called by child controllers
-(void) flagPerspective;

@end
