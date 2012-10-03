//
//  ConfirmNewPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"

@interface ConfirmNewPlaceController : UIViewController<UIGestureRecognizerDelegate, ASIHTTPRequestDelegate, MBProgressHUDDelegate> {
    NSDictionary *categories;
    NSDictionary *addressComponents;
    
    CLLocationCoordinate2D location;
    
    NSString *placeName;
    NSString *selectedCategory;
    
    
    UILabel *placeNameLabel;
    UILabel *categoryLabel;
    UITextField *address;
    UITextField *city;
    
    UIImageView *mapView;
    MBProgressHUD *hud;
}

@property(nonatomic, assign) CLLocationCoordinate2D location;
@property(nonatomic, retain) NSDictionary *categories;
@property(nonatomic, retain) NSDictionary *addressComponents;
@property(nonatomic, retain) NSString *placeName;
@property(nonatomic, retain) NSString *selectedCategory;

@property(nonatomic, retain) IBOutlet UILabel *placeNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *categoryLabel;
@property(nonatomic, retain) IBOutlet UITextField *address;
@property(nonatomic, retain) IBOutlet UITextField *city;
@property(nonatomic, retain) IBOutlet UIImageView *mapView;


-(void) confirmPlace;

@end
