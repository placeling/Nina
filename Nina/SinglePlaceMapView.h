//
//  SinglePlaceMapView.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NinaHelper.h"
#import "Place.h"
#import "PlaceMark.h"

@interface SinglePlaceMapView : UIViewController<MKMapViewDelegate>{
    Place *_place;
    IBOutlet MKMapView *mapView;
    IBOutlet UIToolbar *toolbar;
    
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) Place *place;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;


- (id)initWithPlace:(Place *)place;
-(IBAction) spawnMapApp;

@end
