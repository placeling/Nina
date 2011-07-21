//
//  NearbyPlacesViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequestDelegate.h"
#import "NinaHelper.h"
#import "EGORefreshTableHeaderView.h"


@interface NearbyPlacesViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {
    EGORefreshTableHeaderView *refreshHeaderView;
    
    CLLocationManager *locationManager;
    IBOutlet UITableView *tableView;
    NSArray  *nearbyPlaces;
    
    BOOL _reloading;
    
}

@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property(nonatomic, retain) CLLocationManager *locationManager; 
@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end
