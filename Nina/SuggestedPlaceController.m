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

@synthesize popularLoaded, followingLoaded, locationEnabled, initialIndex;
@synthesize searchTerm, category;
@synthesize lat, lng;
@synthesize followingPlaces, popularPlaces;
@synthesize toolbar, segmentedControl;
@synthesize ad;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (id) init {
    self = [super init];
    if (self != nil) {
        self.followingPlaces = [[[NSMutableArray alloc] init] autorelease];
        self.popularPlaces = [[[NSMutableArray alloc] init] autorelease];
        followingLoaded = TRUE;
        popularLoaded = TRUE;
    }
    return self;
}

-(bool)dataLoaded{
    if(self.segmentedControl.selectedSegmentIndex == 0){
        return followingLoaded;
    } else {
        return popularLoaded;
    }
}

-(NSMutableArray*)places{
    if(self.segmentedControl.selectedSegmentIndex == 0){
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
    
    if (!lat || !lng){
        CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
        CLLocation *location = manager.location;
        
        if (![CLLocationManager  locationServicesEnabled] || !location){
            self.followingLoaded = true;
            self.popularLoaded = true;
            self.locationEnabled = FALSE;
            
            DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
            return;
        }
        
        self.lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
		self.lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }       
        
    NSString *queryString = [NinaHelper encodeForUrl:self.searchTerm];
    NSString *categoryString = [NinaHelper encodeForUrl:self.category];
    
    self.locationEnabled = TRUE;
    
    NSString *currentUser = [NinaHelper getUsername];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    if (currentUser) {   
        NSString *followingUrlString = [NSString stringWithFormat:@"/v1/places/suggested?socialgraph=true&barrie=true&lat=%@&lng=%@&query=%@&category=%@", lat, lng, queryString, categoryString];
        [objectManager loadObjectsAtResourcePath:followingUrlString delegate:self block:^(RKObjectLoader* loader) {        
            loader.userData = [NSNumber numberWithInt:80];
        }];
        self.followingLoaded = false;
    } else {
        self.followingLoaded = true;
    }
    
    NSString *popularUrlString = [NSString stringWithFormat:@"/v1/places/suggested?socialgraph=false&barrie=true&lat=%@&lng=%@&query=%@&category=%@", lat, lng, queryString, categoryString];
    
    [objectManager loadObjectsAtResourcePath:popularUrlString delegate:self block:^(RKObjectLoader* loader) {        
        loader.userData = [NSNumber numberWithInt:81];
    }];
    self.popularLoaded = false;
}



#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 80){
        self.followingLoaded = TRUE;
        [followingPlaces removeAllObjects];
        for (NSObject* object in objects){
            if ([object isKindOfClass:[Advertisement class]]){
                self.ad = (Advertisement*)object;
            } else {
                [followingPlaces addObject:object];
            }
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 81){
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
        self.segmentedControl.selectedSegmentIndex = 1;
    } else {
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    
    if (initialIndex != 0 ){
        self.segmentedControl.selectedSegmentIndex = initialIndex;
    }
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleToolBar:self.toolbar];
    
    
    if (self.category &&  [self.category length] > 0){
        self.navigationItem.title = self.category;
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
    [searchTerm release];
    [category release];
    [followingPlaces release];
    [popularPlaces release];
    [lat release];
    [lng release];
    [ad release];
    [super dealloc];
}

@end
