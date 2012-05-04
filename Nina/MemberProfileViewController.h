//
//  MemberProfileViewController.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-16.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "NinaHelper.h"
#import "ApplicationController.h"
#import "ASIHTTPRequestDelegate.h"
#import "ProfileDetailBadge.h"
#import "LoginController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <RestKit/RestKit.h>
#import "PerspectiveDisplayProtocol.h"

@interface MemberProfileViewController : ApplicationController<ASIHTTPRequestDelegate, LoginControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate, RKObjectLoaderDelegate, PerspectiveDisplayProtocol> {
	NSString *username;
	User *_user;
    BOOL loadingMore;
    BOOL hasMore;
    
    NSMutableArray *perspectives;
    
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *locationLabel;
    
    IBOutlet UILabel *userDescriptionLabel;
    IBOutlet UIButton *followButton;
    
    IBOutlet ProfileDetailBadge *followersButton;
    IBOutlet ProfileDetailBadge *followingButton;
    IBOutlet ProfileDetailBadge *placeMarkButton;
    
    IBOutlet UIView *headerView;
    UITableView *_tableView;
    
    NSMutableSet *expandedIndexPaths;
    
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSMutableArray *perspectives;

@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *userDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;

@property (nonatomic, retain) IBOutlet UIButton *followButton;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet ProfileDetailBadge *followersButton;
@property (nonatomic, retain) IBOutlet ProfileDetailBadge *followingButton;
@property (nonatomic, retain) IBOutlet ProfileDetailBadge *placeMarkButton;

-(IBAction) followUser;
-(IBAction) userPerspectives;
-(IBAction) userFollowing;
-(IBAction) userFollowing;
-(void) loadData; //this is public as the edit perspective controller might want to trigger a refresh
-(void) mainContentLoad; // public as child controllers may call to refresh content

@end
