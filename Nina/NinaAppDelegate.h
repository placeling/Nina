//
//  NinaAppDelegate.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NinaAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    CLLocationManager *locationManager; //not sure if "always" need, but kind of nice for now
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
