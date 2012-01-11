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

@synthesize popularLoaded, followingLoaded, locationEnabled;
@synthesize searchTerm, category;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Login delegate methods
- (void) loadContent {
    [self findNearbyPlaces];
}


-(void)findNearbyPlaces {
	
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = manager.location;
    
	if (location != nil){ //[now timeIntervalSinceDate:location.timestamp] < (60 * 5)){
        
		NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
		NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        
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
        
	} else {
        self.followingLoaded = true;
        self.popularLoaded = true;
        self.locationEnabled = FALSE;
        
        DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
    }
    
}



#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 80){
        self.followingLoaded = TRUE;
        [followingPlaces removeAllObjects];
        for (Place* place in objects){
            [followingPlaces addObject:place];
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 81){
        self.popularLoaded = TRUE;
        [popularPlaces removeAllObjects];
        for (Place* place in objects){
            [popularPlaces addObject:place];
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
    
    
    followingPlaces = [[NSMutableArray alloc] init];
    popularPlaces = [[NSMutableArray alloc] init];
    
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
    [super dealloc];
}

@end
