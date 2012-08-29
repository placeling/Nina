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
#import "LoginController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "Facebook.h"
#import <RestKit/RestKit.h>
#import "PerspectiveDisplayProtocol.h"

typedef enum {
    home,
    following,
    everyone
} PerspectiveTypes;


//#import "EditViewController.h"

@interface PlacePageViewController : ApplicationController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,BookmarkTableViewDelegate, EditPerspectiveDelegate, ASIHTTPRequestDelegate, CustomSegmentedControlDelegate, LoginControllerDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate, RKObjectLoaderDelegate, PerspectiveDisplayProtocol, UIWebViewDelegate> {
    NSString *place_id; 
    NSString *perspective_id; 
    NSString *google_ref;
    
    Place *_place;
    Perspective *myPerspective;
    NSString *referrer;
    
    UIImage *mapImage; // Static Google Map of Location
    BOOL mapRequested;
    PerspectiveTypes perspectiveType;
    NSNumber *initialSelectedIndex;
    
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
    UITableView *_tableView;
    
    NSMutableArray *homePerspectives;
    NSMutableArray *followingPerspectives;
    NSMutableArray *everyonePerspectives;
    
    IBOutlet UIScrollView *tagScrollView;
    
    NSDictionary* buttons;
    
    NSArray *expandedCells;
    
    UIWebView *attributionView;
}

@property BOOL dataLoaded;

@property (nonatomic, retain) NSString *place_id;
@property (nonatomic, retain) NSString *google_ref;
@property (nonatomic, retain) NSString *perspective_id; 
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) UIImage *mapImage;
@property (nonatomic, retain) NSNumber *initialSelectedIndex;

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
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet CustomSegmentedControl *segmentedControl;
@property (nonatomic, assign) PerspectiveTypes perspectiveType;

@property (nonatomic, assign) NSMutableArray *homePerspectives;
@property (nonatomic, assign) NSMutableArray *followingPerspectives;
@property (nonatomic, assign) NSMutableArray *everyonePerspectives;

@property (nonatomic, retain) IBOutlet UIScrollView *tagScrollView;

@property (nonatomic, retain) IBOutlet UIWebView *attributionView;

@property(nonatomic, retain) NSString *referrer;

-(IBAction) googlePlacePage;
-(IBAction) bookmark;

-(void) showShareSheet;

-(IBAction)editPerspective;

-(IBAction)tagSearch:(id)sender;

- (id) initWithPlace:(Place *)place;

-(void) mainContentLoad; // Public as child controllers may recall to refresh data

@end
