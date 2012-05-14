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

@implementation SuggestedPlaceController

@synthesize popularLoaded, followingLoaded, myLoaded, locationEnabled;
@synthesize searchTerm, category, navTitle, initialIndex;
@synthesize origin, latitudeDelta;
@synthesize followingPlaces, popularPlaces, myPlaces;
@synthesize toolbar, segmentedControl;
@synthesize ad;

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
        self.latitudeDelta = 0.005;
    }
    return self;
}

-(bool)dataLoaded{
    if ( self.segmentedControl.selectedSegmentIndex == 0 ){
        return myLoaded;
    } else if ( self.segmentedControl.selectedSegmentIndex == 1 ){
        return followingLoaded;
    } else {
        return popularLoaded;
    }
}

-(NSMutableArray*)places{
    if( self.segmentedControl.selectedSegmentIndex == 0 ){
        return self.myPlaces;
    } else if ( self.segmentedControl.selectedSegmentIndex == 1 ){
        return self.followingPlaces;
    } else {
        return self.popularPlaces;
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
    
    if ( currentUser &&  self.segmentedControl.selectedSegmentIndex == 0 ){
        requestUrl = [NSString stringWithFormat:@"/v1/places/suggested?query_type=me&barrie=true&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];

        requestTag = [NSNumber numberWithInt:80];
        self.myLoaded = false;
    } else if ( currentUser &&  self.segmentedControl.selectedSegmentIndex == 1 ){
        requestUrl = [NSString stringWithFormat:@"/v1/places/suggested?query_type=following&barrie=true&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];
        
        requestTag = [NSNumber numberWithInt:81];
        self.followingLoaded = false;
    } else {
        requestUrl = [NSString stringWithFormat:@"/v1/places/suggested?query_type=popular&barrie=true&lat=%f&lng=%f&span=%f&query=%@&category=%@", origin.latitude, origin.longitude, self.latitudeDelta, queryString, categoryString];
        requestTag = [NSNumber numberWithInt:82];
        self.popularLoaded = false;
    }
   
    [objectManager loadObjectsAtResourcePath:requestUrl delegate:self block:^(RKObjectLoader* loader) {        
        loader.userData = requestTag;
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
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
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
    if ( !currentUser ){
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
    
    if ( self.navTitle){
        self.navigationItem.title = self.navTitle;
    } else if ( self.searchTerm ) {
        self.navigationItem.title = self.searchTerm;
    } else {
        self.navigationItem.title = @"Nearby";
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [super dealloc];
}

@end
