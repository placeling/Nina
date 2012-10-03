//
//  FindFacebookFriendsController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaAppDelegate.h"

@interface FindFacebookFriendsController : UIViewController<UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate>{    
    bool loading;
    NSMutableArray *searchUsers;
    UITableView *_tableView;
}

@property(nonatomic, retain) NSMutableArray *facebookFriends; 
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
