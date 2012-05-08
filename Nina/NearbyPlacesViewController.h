//
//  NearbyPlacesViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "User.h"
#import "NinaHelper.h"
#import "MBProgressHUD.h"


@interface NearbyPlacesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate, UISearchBarDelegate, MBProgressHUDDelegate> {
    EGORefreshTableHeaderView *refreshHeaderView;
    
    IBOutlet UIView *tableFooterView;
    IBOutlet UITableView *placesTableView;
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UILabel *gpsLabel;
    CLLocation *_location;
    
    NSMutableArray  *nearbyPlaces;
    NSMutableArray  *predictivePlaces;
    
    BOOL showPredictive;
    BOOL narrowed;
    BOOL dataLoaded;
    bool loading;

    BOOL locationEnabled;
    BOOL _reloading;
    BOOL promptAdd;
    MBProgressHUD *HUD;
    bool searchLogged;
    NSTimer *timer;
    
    CLLocation *hardLocation;
    NSNumber *hardAccuracy;
}

@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property(nonatomic, retain) IBOutlet UITableView *placesTableView;
@property(nonatomic, retain) IBOutlet IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UIView *tableFooterView;
@property(nonatomic, retain) IBOutlet UILabel *gpsLabel;
@property(nonatomic,assign) BOOL dataLoaded;

@property(nonatomic, retain) CLLocation *hardLocation;
@property(nonatomic, retain) NSNumber *hardAccuracy;

@property(nonatomic, assign) BOOL locationEnabled;
@property(nonatomic, retain) CLLocation *location;

@end
