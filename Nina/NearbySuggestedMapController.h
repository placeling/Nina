//
//  NearbySuggestedMapController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SuggestedPlaceController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequest.h"
#import "User.h"
#import "LoginController.h"
#import "CMPopTipView.h"

@class PerspectiveUserTableViewController;
@class PerspectiveTagTableViewController;

@interface NearbySuggestedMapController : SuggestedPlaceController<MKMapViewDelegate, SuggestedFilterProtocol, CMPopTipViewDelegate> {
    
    PerspectiveUserTableViewController *userChild;
    PerspectiveTagTableViewController *tagChild;
    
    MKMapView *_mapView;    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D lastCoordinate;
    CLLocationDegrees lastLatSpan;
    UIActivityIndicatorView *spinnerView;
    UIToolbar *bottomToolBar;
    
    UIBarButtonItem *showPeopleButton;
    UIBarButtonItem *showTagsButton;
    
    UIButton *placemarkButton;
    
    NSTimer *timer;
    NSString *place_id;
    
    CMPopTipView *usernameButton;
    CMPopTipView *hashtagButton;
    
    NSMutableArray *placeSuperset;
    
    bool viewLoaded;
    bool shownPopup;
}

@property(nonatomic, retain) NSString *place_id;
@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinnerView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) IBOutlet UIToolbar *bottomToolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *showPeopleButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *showTagsButton;
@property(nonatomic, retain) CMPopTipView *usernameButton;
@property(nonatomic, retain) CMPopTipView *hashtagButton;
@property(nonatomic, retain) IBOutlet UIButton *placemarkButton;

-(IBAction)reloadMap;
-(IBAction)changeTab;

-(IBAction)showPeople;
-(IBAction)showTags;
-(IBAction)showNearbyPlaces;

@end
