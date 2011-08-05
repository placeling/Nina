//
//  NearbyPlacesViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "AttachPerspectiveViewController.h"


@interface NearbyPlacesViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {
    EGORefreshTableHeaderView *refreshHeaderView;
    
    CLLocationManager *locationManager;
    IBOutlet UITableView *placesTableView;
    NSArray  *nearbyPlaces;
    
    BOOL needLocationUpdate;
    BOOL _reloading;
    
}

@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property(nonatomic, retain) CLLocationManager *locationManager; 
@property(nonatomic, retain) IBOutlet UITableView *placesTableView;

@end
