//
//  NewPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import "CategoryController.h"


@interface NewPlaceController : UIViewController<MKMapViewDelegate, ASIHTTPRequestDelegate, UIGestureRecognizerDelegate, CategoryControllerDelegate>{
    NSString *_placeName;
    
    UITextField *placeNameField;
    UILabel *placeLatLngField;
    UITextField *placeCategoryField;
    UIImageView *crosshairView;
    
    NSDictionary *categories;
    NSDictionary *addressComponents;
    
    MKMapView *mapView;
    NSTimer *timer;
}

@property(nonatomic,retain) NSString *placeName;

@property(nonatomic,retain) IBOutlet UITextField *placeNameField;
@property(nonatomic,retain) IBOutlet UILabel *placeLatLngField;
@property(nonatomic,retain) IBOutlet UITextField *placeCategoryField;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIImageView *crosshairView;
@property(nonatomic, retain) NSDictionary *categories;
@property(nonatomic, retain) NSDictionary *addressComponents;

- (id)initWithName:(NSString *)placeName;
-(void)reverseGeocode;
-(IBAction)pickCategoryPopup;
-(void)confirmPlace;
    
@end
