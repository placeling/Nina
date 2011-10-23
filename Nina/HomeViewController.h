//
//  HomeViewController.h
//  
//
//  Created by Ian MacKinnon on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController<UIActionSheetDelegate>{
    IBOutlet UIScrollView *pickScroll;
    IBOutlet UIView *scrollFooter;
}

@property (nonatomic, retain) IBOutlet UIScrollView *pickScroll;
@property (nonatomic, retain) IBOutlet UIView *scrollFooter;

-(IBAction) activityFeed;

-(IBAction) suggested;

-(IBAction) bookmarkSpot;
-(IBAction) nearbyPerspectives;
-(IBAction) random;
-(IBAction) showAccountSheet;

-(IBAction) everythingList;

-(IBAction) showLogin;

-(IBAction) logout;
-(IBAction) myProfile;

@end
