//
//  AttachPerspectiveViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AttachPerspectiveViewController : UIViewController {
    NSDictionary *rawPlace;
    IBOutlet UILabel *placeName;
    IBOutlet UITextView *perspective;
    IBOutlet UIButton *postButton;
    CLLocationManager *locationManager;
}

@property(nonatomic,retain) NSDictionary *rawPlace;
@property(nonatomic,retain) IBOutlet UILabel *placeName;
@property(nonatomic,retain) IBOutlet UITextView *perspective;
@property(nonatomic,retain) IBOutlet UIButton *postButton;
@property(nonatomic,retain) CLLocationManager *locationManager;

-(IBAction) postPerspective;

@end
