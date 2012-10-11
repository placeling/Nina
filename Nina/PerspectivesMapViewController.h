//
//  PerspectivesMapViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "User.h"
#import "LoginController.h"

@interface PerspectivesMapViewController : UIViewController<RKObjectLoaderDelegate, MKMapViewDelegate, LoginControllerDelegate> {
    IBOutlet MKMapView *_mapView;
    IBOutlet UIToolbar *toolbar;
    NSString *_username;
    NSMutableArray *nearbyMarks;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D lastCoordinate;
    CLLocationDegrees lastLatSpan;
    User *user; //user this is representing
    UIActivityIndicatorView *spinnerView;  
    BOOL mapLoaded;
    NSTimeInterval userTime;
    
    UIBarButtonItem *showMineButton;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinnerView;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSMutableArray *nearbyMarks;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) User *user;
@property(nonatomic, assign) NSTimeInterval userTime;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *showMineButton;

-(IBAction)recenter;
-(IBAction)refreshMap;
-(IBAction)showMine;

- (id) initForUserName:(NSString *)username;

@end
