//
//  SuggestedPlaceController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SuggestedPlaceController.h"
#import "NSString+SBJSON.h"
#import "PlacePageViewController.h"
#import "PlaceSuggestTableViewCell.h"
#import "Place.h"
#import "LoginController.h"
#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "PlaceMark.h"

#import "FlurryAnalytics.h"
#import "PerspectiveUserTableViewController.h"
#import "PerspectiveTagTableViewController.h"

@implementation SuggestedPlaceController

@synthesize popularLoaded, followingLoaded, myLoaded, locationEnabled;
@synthesize searchTerm, category, navTitle, initialIndex;
@synthesize origin, latitudeDelta, userTime;
@synthesize followingPlaces, popularPlaces, myPlaces;
@synthesize toolbar, segmentedControl;
@synthesize userFilter, tagFilter;
@synthesize ad, quickpick;

@synthesize bottomToolBar, showPeopleButton, showTagsButton, usernameButton, hashtagButton;

-(NSSet*)visiblePlaces{
    return nil; //shouldn't be directly called
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (id) init {
    self = [super init];
    if (self != nil) {
        self.followingPlaces = [[[NSMutableArray alloc] init] autorelease];
        self.popularPlaces = [[[NSMutableArray alloc] init] autorelease];
        self.myPlaces = [[[NSMutableArray alloc] init] autorelease];
        followingLoaded = FALSE;
        popularLoaded = FALSE;
        myLoaded = FALSE;
        initialIndex = 1;
        quickpick = false;
        self.latitudeDelta = 0.005;
        User *user = [UserManager sharedMeUser];
        if (user) {
            self.userTime = user.timestamp;
        }
    }
    return self;
}

-(bool)dataLoaded{
    if ( quickpick ){
        return popularLoaded;
    } else {
        if ( self.segmentedControl.selectedSegmentIndex == 0 ){
            return myLoaded;
        } else if ( self.segmentedControl.selectedSegmentIndex == 1 ){
            return followingLoaded;
        } else {
            return popularLoaded;
        }
    }
}

-(NSMutableArray*)places{
    if (quickpick){
        return popularPlaces;
    } else {
        if( self.segmentedControl.selectedSegmentIndex == 0 ){
            return self.myPlaces;
        } else if ( self.segmentedControl.selectedSegmentIndex == 1 ){
            return self.followingPlaces;
        } else {
            return self.popularPlaces;
        }
    }
}


-(IBAction)toggleMapList{
    DLog(@"This shouldn't be called, it's an abstract method");
}

-(void)loadContent{
    DLog(@"This shouldn't be called, it's an abstract method");
}

-(void)findNearbyPlaces {
    
    if ( origin.latitude == 0.0 && origin.longitude == 0.0 ){
        CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
        CLLocation *location = manager.location;
        
        if (![CLLocationManager  locationServicesEnabled] || !location){
            self.followingLoaded = true;
            self.popularLoaded = true;
            self.myLoaded = true;
            self.locationEnabled = FALSE;
            
            DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
            return;
        }
        
        self.origin = location.coordinate;
    }       
        
    NSString *queryString = [NinaHelper encodeForUrl:self.searchTerm];
    NSString *categoryString = [NinaHelper encodeForUrl:self.category];
    
    self.locationEnabled = TRUE;
    
    NSString *currentUser = [NinaHelper getUsername];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    NSString *requestUrl;
    NSNumber *requestTag;
    
    
    if ( quickpick ){
        requestUrl = [NSString stringWithFormat:@"/v1/places/quickpick?&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];
        requestTag = [NSNumber numberWithInt:83];
        self.popularLoaded = false;     
    } else {
        if ( currentUser &&  self.segmentedControl.selectedSegmentIndex == 0 ){
            requestUrl = [NSString stringWithFormat:@"/v1/places/suggested?query_type=me&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];

            requestTag = [NSNumber numberWithInt:80];
            self.myLoaded = false;
        } else if ( currentUser &&  self.segmentedControl.selectedSegmentIndex == 1 ){
            requestUrl = [NSString stringWithFormat:@"/v1/places/suggested?query_type=following&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];
            
            requestTag = [NSNumber numberWithInt:81];
            self.followingLoaded = false;
        } else {
            requestUrl = [NSString stringWithFormat:@"/v1/places/suggested?query_type=popular&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];
            requestTag = [NSNumber numberWithInt:82];
            self.popularLoaded = false;
        }
    }
   
    [objectManager loadObjectsAtResourcePath:requestUrl usingBlock:^(RKObjectLoader* loader) {
        loader.userData = requestTag;
        loader.delegate = self;
    }];

}



#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 80 ){
        self.myLoaded = TRUE;
        [myPlaces removeAllObjects];
        for (NSObject* object in objects){
            if ([object isKindOfClass:[Advertisement class]]){
                self.ad = (Advertisement*)object;
            } else {
                [myPlaces addObject:object];
            }
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 81 ){
        self.followingLoaded = TRUE;
        [followingPlaces removeAllObjects];
        for (NSObject* object in objects){
            if ([object isKindOfClass:[Advertisement class]]){
                self.ad = (Advertisement*)object;
            } else {
                [followingPlaces addObject:object];
            }
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 82 ){
        self.popularLoaded = TRUE;
        [popularPlaces removeAllObjects];
        for (NSObject* object in objects){
            if ([object isKindOfClass:[Advertisement class]]){
                self.ad = (Advertisement*)object;
            } else {
                [popularPlaces addObject:object];
            }
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 83 ){
        self.popularLoaded = TRUE;
        [popularPlaces removeAllObjects];
        for (NSObject* object in objects){
            if ([object isKindOfClass:[Advertisement class]]){
                self.ad = (Advertisement*)object;
            } else {
                [popularPlaces addObject:object];
            }
        }
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    if ( popTipView == self.hashtagButton ){
        tagFilter = nil;
    } else {
        userFilter = nil;
    }
}

-(void)setUserFilter:(NSString*)username{
    
    userFilter = username;
    
    if ( userFilter ){
        self.usernameButton = [[[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"%@", userFilter]]autorelease];
        self.usernameButton.backgroundColor = [UIColor colorWithRed:185/255.0 green:43/255.0 blue:52/255.0 alpha:1.0];
        self.usernameButton.delegate = self;
        [self.usernameButton presentPointingAtBarButtonItem:self.showPeopleButton animated:true];
    }
}

-(void)setTagFilter:(NSString*)hashTag{
    
    tagFilter = hashTag;
    
    if ( tagFilter ){
        self.hashtagButton = [[[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"#%@", tagFilter]]autorelease];
        self.hashtagButton.backgroundColor = [UIColor colorWithRed:185/255.0 green:43/255.0 blue:52/255.0 alpha:1.0];
        self.hashtagButton.delegate = self;
        [self.hashtagButton presentPointingAtBarButtonItem:self.showTagsButton animated:true];
    }
}

-(IBAction)showPeople{
    [usernameButton dismissAnimated:true];
    [FlurryAnalytics logEvent:@"QUICKPICK_USER_FILTER"];
    userFilter = nil;
    //reset the hiddenness based on tags
    
    NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
    for ( Place *place in [self visiblePlaces]  ){
        place.hidden = true;
        for (Perspective *perspective in place.placemarks){
            if (!tagFilter || [perspective.tags indexOfObject:tagFilter] != NSNotFound ){
                perspective.hidden = false;
                place.hidden = false;
            } else {
                perspective.hidden = true;
            }
        }
        if ( !place.hidden ){
            [visiblePlaces addObject:place];
            place.hidden = false;
        } 
    }
    
    PerspectiveUserTableViewController *peopleController = [[PerspectiveUserTableViewController alloc] initWithPlaces:visiblePlaces];
    peopleController.delegate = self;
    userChild = peopleController;
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:peopleController];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [peopleController release];
    [visiblePlaces release];
}


-(IBAction)showTags{
    [hashtagButton dismissAnimated:true];
    tagFilter = nil;
    [FlurryAnalytics logEvent:@"QUICKPICK_TAG_FILTER"];
    NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
    
    for ( Place *place in [self visiblePlaces] ){
        place.hidden = true;        
        for (Perspective *perspective in place.placemarks){
            if ( !userFilter || [perspective.user.username isEqualToString:userFilter] ){
                perspective.hidden = false;
                place.hidden = false;
            } else {
                perspective.hidden = true;
            }
        }
        if (!place.hidden){
            [visiblePlaces addObject:place];
        } 
    }
    
    PerspectiveTagTableViewController *tagController = [[PerspectiveTagTableViewController alloc] initWithPlaces:visiblePlaces];
    tagController.delegate = self;
    if ( userFilter ){
        tagController.filteringUser = userFilter;
    }
    tagChild = tagController;
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:tagController];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [tagController release];
    [visiblePlaces release];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (!self.category){
        self.category = @""; //can't be a nil
    }
    
    if (!self.searchTerm){
        self.searchTerm = @"";
    }
    
    NSString *currentUser = [NinaHelper getUsername];
    if ( !currentUser  && self.initialIndex != 0){
        //not logged in, show popular
        self.myLoaded = true;
        self.followingLoaded = true;
        self.segmentedControl.selectedSegmentIndex = 2;
    } else {
        self.segmentedControl.selectedSegmentIndex = self.initialIndex;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleToolBar:self.toolbar];
    [StyleHelper styleToolBar:self.bottomToolBar];
    
    if ( self.navTitle){
        self.navigationItem.title = self.navTitle;
    } else if ( self.searchTerm ) {
        self.navigationItem.title = self.searchTerm;
    } else {
        self.navigationItem.title = @"Nearby";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void) dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [searchTerm release];
    [category release];
    [followingPlaces release];
    [myPlaces release];
    [popularPlaces release];
    [navTitle release];
    [ad release];
    
    [hashtagButton release];
    [showTagsButton release];
    
    [bottomToolBar release];
    
    [super dealloc];
}

@end
