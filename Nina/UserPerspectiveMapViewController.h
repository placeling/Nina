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


@interface UserPerspectiveMapViewController : UIViewController<ASIHTTPRequestDelegate, CLLocationManagerDelegate> {
    IBOutlet MKMapView *mapView;
    NSString *userName;
    NSArray *nearbyPlaces;
    BOOL needLocationUpdate; 
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) NSString *userName;
@property(nonatomic, retain) NSArray *nearbyPlaces;

@end
