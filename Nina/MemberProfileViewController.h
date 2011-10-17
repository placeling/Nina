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
#import "ASIHTTPRequestDelegate.h"
#import "ProfileDetailBadge.h"
#import "asyncimageview.h"

@interface MemberProfileViewController : UITableViewController<ASIHTTPRequestDelegate> {
	NSString *username;
	User *user;
    BOOL loadingMore;
    BOOL hasMore;
    
    NSMutableArray *perspectives;
    
    IBOutlet AsyncImageView *profileImageView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *locationLabel;
    
    IBOutlet UILabel *userDescriptionLabel;
    IBOutlet UIButton *followButton;
    
    IBOutlet ProfileDetailBadge *followersButton;
    IBOutlet ProfileDetailBadge *followingButton;
    IBOutlet ProfileDetailBadge *placeMarkButton;
    
    IBOutlet UIView *headerView;
    
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) User *user;

@property (nonatomic, retain) IBOutlet AsyncImageView *profileImageView;

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *userDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;

@property (nonatomic, retain) IBOutlet UIButton *followButton;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) IBOutlet ProfileDetailBadge *followersButton;
@property (nonatomic, retain) IBOutlet ProfileDetailBadge *followingButton;
@property (nonatomic, retain) IBOutlet ProfileDetailBadge *placeMarkButton;


-(IBAction) followUser;
-(IBAction) userPerspectives;
-(IBAction) userFollowing;
-(IBAction) userFollowing;
-(void) loadData; //this is public as the edit perspective controller might want to trigger a refresh

@end
