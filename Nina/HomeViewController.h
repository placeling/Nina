//
//  HomeViewController.h
//  
//
//  Created by Ian MacKinnon on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomBadge.h"


@interface HomeViewController : UIViewController<UIActionSheetDelegate>{
    IBOutlet UIScrollView *pickScroll;
    IBOutlet UIView *scrollFooter;
    
    UILabel *mapLabel;
    UILabel *feedLabel;
    UILabel *profileLabel;
    UILabel *peopleLabel;

    UIButton *placemarkButton;
    
    CustomBadge *customBadge;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *pickScroll;
@property (nonatomic, retain) IBOutlet UIView *scrollFooter;
@property (nonatomic, retain) IBOutlet UILabel *mapLabel;
@property (nonatomic, retain) IBOutlet UILabel *feedLabel;
@property (nonatomic, retain) IBOutlet UILabel *profileLabel;
@property (nonatomic, retain) IBOutlet UILabel *peopleLabel;
@property (nonatomic, retain) IBOutlet UIButton *placemarkButton;

-(IBAction) activityFeed:(id)sender;

-(IBAction) bookmarkSpot;
-(IBAction) nearbyPerspectives;
-(IBAction) showAccountSheet;

-(IBAction) everythingList;

-(IBAction) showLogin;

-(IBAction) logout;
-(IBAction) myProfile;
-(IBAction) questions;

-(IBAction) findFriends;

-(void)refreshNotificationBadge;

@end
