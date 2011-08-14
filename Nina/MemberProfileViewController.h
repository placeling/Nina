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
#import "TTTQuadrantControl.h"

@interface MemberProfileViewController : UIViewController<ASIHTTPRequestDelegate, UITableViewDelegate> {
	NSString *username;
	User *user;
    
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *userDescriptionLabel;
    IBOutlet UIButton *followButton;
    IBOutlet UITableView *tableView;
    IBOutlet TTTQuadrantControl *quadControl;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) User *user;

@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *userDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton *followButton;
@property (nonatomic, retain) IBOutlet TTTQuadrantControl *quadControl;

-(IBAction) followUser;
-(IBAction) userPerspectives;

@end
