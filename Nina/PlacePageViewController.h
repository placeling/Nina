//
//  PlacePageViewController.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-23.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"
#import "Place.h"
#import "User.h"
#import "ASIHTTPRequestDelegate.h"
#import "NinaHelper.h"

//#import "EditViewController.h"

@interface PlacePageViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate> {        
    NSString *google_id; 
    NSString *google_ref;
    
    Place *_place;
    UIImage *mapImage; // Static Google Map of Location
    
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *phoneButton;
    IBOutlet UIButton *googlePlacesButton;
    IBOutlet UIButton *websiteButton;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *cityLabel;
    IBOutlet UILabel *categoriesLabel;
    
    IBOutlet UIImageView *mapImageView;
    IBOutlet UISegmentedControl *segmentedControl;    
}

@property BOOL dataLoaded;

@property (nonatomic, retain) NSString *google_id;
@property (nonatomic, retain) NSString *google_ref;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) UIImage *mapImage;

@property (nonatomic, retain) IBOutlet UIButton *googlePlacesButton;
@property (nonatomic, retain) IBOutlet UIButton *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIButton *phoneButton;
@property (nonatomic, retain) IBOutlet UIButton *websiteButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet UILabel *categoriesLabel;
@property (nonatomic, retain) IBOutlet UIImageView *mapImageView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

-(IBAction) bookmark;
-(IBAction) phonePlace;
-(IBAction) googlePlacePage;
-(IBAction) changedSegment;


- (id) initWithPlace:(Place *)place;

@end
