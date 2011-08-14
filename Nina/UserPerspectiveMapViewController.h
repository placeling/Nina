//
//  UserPerspectiveMapViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequest.h"


@interface UserPerspectiveMapViewController : UIViewController<ASIHTTPRequestDelegate> {
    IBOutlet MKMapView *mapView;
    NSString *userName;
    NSMutableArray *nearbyMarks;
    CLLocationManager *locationManager;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) NSString *userName;
@property(nonatomic, retain) NSMutableArray *nearbyMarks;
@property(nonatomic, retain) CLLocationManager *locationManager;

-(IBAction)recenter;

@end
