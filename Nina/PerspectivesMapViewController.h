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


@interface PerspectivesMapViewController : UIViewController<ASIHTTPRequestDelegate, MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
    NSString *_username;
    NSMutableArray *nearbyMarks;
    CLLocationManager *locationManager;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSMutableArray *nearbyMarks;
@property(nonatomic, retain) CLLocationManager *locationManager;

-(IBAction)recenter;
-(IBAction)refreshMap;

- (id) initForUserName:(NSString *)username;

@end
