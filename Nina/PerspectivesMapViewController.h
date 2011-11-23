//
//  PerspectivesMapViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequest.h"
#import "User.h"
#import "LoginController.h"

@interface PerspectivesMapViewController : UIViewController<ASIHTTPRequestDelegate, MKMapViewDelegate, LoginControllerDelegate> {
    IBOutlet MKMapView *_mapView;
    IBOutlet UIToolbar *toolbar;
    NSString *_username;
    NSMutableArray *nearbyMarks;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D lastCoordinate;
    User *user; //user this is representing
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSMutableArray *nearbyMarks;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) User *user;

-(IBAction)recenter;
-(IBAction)refreshMap;

- (id) initForUserName:(NSString *)username;

@end
