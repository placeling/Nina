//
//  NinaAppDelegate.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationManagerManager.h"
#import "FBConnect.h"

@interface NinaAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate, CLLocationManagerDelegate>{
    Facebook *facebook;
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

-(void) sendBackgroundLocationToServer:(CLLocation*)location;
-(void)localNotification;

@end
