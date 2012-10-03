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


@interface NinaAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate>{
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

-(void) sendBackgroundLocationToServer:(CLLocation*)location;

@end
