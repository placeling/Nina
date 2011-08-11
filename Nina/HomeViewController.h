//
//  HomeViewController.h
//  
//
//  Created by Ian MacKinnon on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController{
    CLLocationManager *manager;
}


-(IBAction) logout;
-(IBAction) perspectives;
-(IBAction) bookmarkSpot;

@end