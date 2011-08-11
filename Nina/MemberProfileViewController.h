//
//  MemberProfileViewController.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-16.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MemberProfileViewController : UITableViewController {
	NSString *username;
	User *user;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) User *user;

@end
