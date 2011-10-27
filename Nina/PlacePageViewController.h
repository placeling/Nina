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
#import "BookmarkTableViewCell.h"
#import "EditPerspectiveViewController.h"
#import "CustomSegmentedControl.h"

typedef enum {
    home,
    following,
    everyone
} PerspectiveTypes;


//#import "EditViewController.h"

@interface PlacePageViewController : UITableViewController <UIActionSheetDelegate,BookmarkTableViewDelegate, EditPerspectiveDelegate, ASIHTTPRequestDelegate, CustomSegmentedControlDelegate> {        
    NSString *place_id; 
    NSString *perspective_id; 
    NSString *google_ref;
    
    Place *_place;
    Perspective *myPerspective;
    User *referrer;
    
    UIImage *mapImage; // Static Google Map of Location
    BOOL mapRequested;
    PerspectiveTypes perspectiveType;
    
    IBOutlet UIButton *googlePlacesButton;
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *cityLabel;
    IBOutlet UILabel *categoriesLabel;
    
    IBOutlet UIButton *mapButtonView;
    IBOutlet CustomSegmentedControl *segmentedControl; 
    IBOutlet UIView *tableHeaderView;
    IBOutlet UIView *topofHeaderView;
    IBOutlet UIView *tableFooterView;
    
    NSMutableArray *perspectives;
    NSMutableArray *homePerspectives;
    NSMutableArray *followingPerspectives;
    NSMutableArray *everyonePerspectives;
    
    IBOutlet UIScrollView *tagScrollView;
    
    NSDictionary* buttons;
}

@property BOOL dataLoaded;

@property (nonatomic, retain) NSString *place_id;
@property (nonatomic, retain) NSString *google_ref;
@property (nonatomic, retain) NSString *perspective_id; 
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) UIImage *mapImage;

@property (nonatomic, retain) IBOutlet UIButton *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIButton *googlePlacesButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet UILabel *categoriesLabel;

@property (nonatomic, retain) IBOutlet UIButton *mapButtonView;
@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UIView *topofHeaderView;

@property (nonatomic, retain) IBOutlet CustomSegmentedControl *segmentedControl;
@property (nonatomic, assign) PerspectiveTypes perspectiveType;

@property (nonatomic, assign) NSMutableArray *homePerspectives;
@property (nonatomic, assign) NSMutableArray *followingPerspectives;
@property (nonatomic, assign) NSMutableArray *everyonePerspectives;

@property (nonatomic, retain) IBOutlet UIScrollView *tagScrollView;

@property(nonatomic, retain) User *referrer;

-(IBAction) googlePlacePage;
-(IBAction) bookmark;

-(void) showShareSheet;

-(IBAction)editPerspective;
-(IBAction)editPerspectivePhotos;

-(IBAction)showSingleAnnotatedMap;

-(IBAction) shareTwitter;
-(IBAction) shareFacebook;
-(IBAction) checkinFoursquare;

-(IBAction)tagSearch:(id)sender;

- (id) initWithPlace:(Place *)place;

@end
