//
//  FollowViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequest.h"
#import "User.h"

@interface FollowViewController : UITableViewController<ASIHTTPRequestDelegate>{
    User* _user;
    NSMutableArray *users;
    bool following;//false for followers, true for following    
}

@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) User *user;
@property(nonatomic,assign) bool following;

- (id)initWithUser:(User*)focusUser andFollowing:(bool)follow;

@end
