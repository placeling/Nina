//
//  ActivityFeedViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "NinaHelper.h"
#import "ActivityTableViewCell.h"
#import "User.h"

@interface ActivityFeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {
    EGORefreshTableHeaderView *refreshHeaderView;
    User *user;
    
    IBOutlet UITableView *activityTableView;
    NSArray  *recentActivities;
    
    BOOL _reloading;
}

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic, retain) IBOutlet UITableView *activityTableView;
@property (nonatomic, retain) User *user;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
