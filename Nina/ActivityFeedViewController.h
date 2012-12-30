//
//  ActivityFeedViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "NinaHelper.h"
#import "ActivityTableViewCell.h"
#import "User.h"
#import "LoginController.h"
#import <RestKit/RestKit.h>

@interface ActivityFeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LoginControllerDelegate, RKObjectLoaderDelegate, EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    UITableView *activityTableView;
    NSMutableArray  *recentActivities;
    NSMutableArray  *recentNotifications;
    UISegmentedControl *segmentControl;
    UIToolbar *toolbar;
    BOOL loadingMore;
    BOOL hasMoreNotifications;
    BOOL hasMore;
    BOOL _reloading;
    
    NSInteger initialIndex;
}

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic, retain) IBOutlet UITableView *activityTableView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentControl; 
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, assign) NSInteger initialIndex;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

-(IBAction) toggleType;

@end
