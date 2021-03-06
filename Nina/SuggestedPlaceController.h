//
//  SuggestedPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "LoginController.h"
#import <RestKit/RestKit.h>
#import "Place.h"
#import "Advertisement.h"
#import "CMPopTipView.h"

@class PerspectiveUserTableViewController;
@class PerspectiveTagTableViewController;

@protocol SuggestedFilterProtocol
-(void) setUserFilter:(NSString*)username;
-(void) setTagFilter:(NSString*)hashTag;
@end

@interface SuggestedPlaceController : UIViewController<LoginControllerDelegate, RKObjectLoaderDelegate, CMPopTipViewDelegate, SuggestedFilterProtocol>{
    BOOL locationEnabled;
    
    BOOL myLoaded;
    BOOL followingLoaded;
    BOOL popularLoaded;
    
    int initialIndex;
    
    NSMutableArray  *followingPlaces;
    NSMutableArray  *popularPlaces;
    NSMutableArray  *myPlaces;
    
    CLLocationCoordinate2D origin;
    float latitudeDelta;
    
    NSString *searchTerm;
    NSString *category;
    NSString *navTitle;
    
    NSString *userFilter;
    NSString *tagFilter;
    
    Advertisement *ad;
    NSTimeInterval userTime;
    BOOL quickpick;
    
    UIToolbar *bottomToolBar;
    
    UIBarButtonItem *showPeopleButton;
    UIBarButtonItem *showTagsButton;
    
    CMPopTipView *usernameButton;
    CMPopTipView *hashtagButton;    
    
    PerspectiveUserTableViewController *userChild;
    PerspectiveTagTableViewController *tagChild;
}

@property(nonatomic, assign) BOOL followingLoaded;
@property(nonatomic, assign) BOOL popularLoaded;
@property(nonatomic, assign) BOOL myLoaded;
@property(nonatomic, assign) BOOL locationEnabled;
@property(nonatomic, assign) int initialIndex;;

@property(nonatomic,retain) NSString *searchTerm;
@property(nonatomic,retain) NSString *category;

@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

@property(nonatomic,assign) CLLocationCoordinate2D origin;
@property(nonatomic,assign) float latitudeDelta;
@property (nonatomic, assign) NSTimeInterval userTime;

@property(nonatomic,retain) NSMutableArray  *followingPlaces;
@property(nonatomic,retain) NSMutableArray  *popularPlaces;
@property(nonatomic,retain) NSMutableArray  *myPlaces;

@property(nonatomic,retain) Advertisement *ad;

@property(nonatomic, retain) NSString *navTitle;

@property(nonatomic, retain) NSString *userFilter;
@property(nonatomic, retain) NSString *tagFilter;

@property(nonatomic, assign) BOOL quickpick;

@property(nonatomic, retain) IBOutlet UIToolbar *bottomToolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *showPeopleButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *showTagsButton;

@property(nonatomic, retain) CMPopTipView *usernameButton;
@property(nonatomic, retain) CMPopTipView *hashtagButton;

-(IBAction)showPeople;
-(IBAction)showTags;

-(void)findNearbyPlaces;
-(IBAction)toggleMapList;

-(bool)dataLoaded;
-(NSMutableArray*)places;
-(NSMutableArray*)visiblePlaces;

@end
