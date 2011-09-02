//
//  HomeViewController.h
//  
//
//  Created by Ian MacKinnon on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController<UIActionSheetDelegate>

-(IBAction) suggested;

-(IBAction) bookmarkSpot;
-(IBAction) nearbyPerspectives;
-(IBAction) random;
-(IBAction)showAccountSheet;


-(IBAction) logout;
-(IBAction) myProfile;

@end
