//
//  NearbySuggestedMapController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+SBJSON.h"
#import "PerspectivePlaceMark.h"
#import "PlaceMark.h"
#import "Perspective.h"
#import "PlacePageViewController.h"
#import "LoginController.h"
#import "User.h"
#import "Place.h"
#import "NearbySuggestedPlaceController.h"
#import "NearbySuggestedMapController.h"
#import "PerspectiveUserTableViewController.h"
#import "FlurryAnalytics.h"

@interface NearbySuggestedMapController (Private)
-(void)mapPlaces;
-(void)updateMapView;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
@end

@implementation NearbySuggestedMapController

@synthesize mapView=_mapView, spinnerView;
@synthesize locationManager, bottomToolBar, showPeopleButton;

-(IBAction)toggleMapList{
    NearbySuggestedPlaceController *nsController = [[NearbySuggestedPlaceController alloc] init];        
    
    nsController.followingPlaces = self.followingPlaces;
    nsController.popularPlaces = self.popularPlaces;
    nsController.category = self.category;
    nsController.searchTerm = self.searchTerm;
    nsController.initialIndex = self.segmentedControl.selectedSegmentIndex;
    
    UINavigationController *navController = self.navigationController;
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:
     UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    [controllers removeLastObject];
    navController.viewControllers = controllers;
    
    [navController pushViewController:nsController animated: YES];
    [UIView commitAnimations];

}

-(IBAction)showPeople{
    
    PerspectiveUserTableViewController *peopleController = [[PerspectiveUserTableViewController alloc] initWithPlaces:[self places]];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:peopleController];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [peopleController release];
}


-(IBAction)mapPlaces{    
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (Place *place in [self places]){        
        DLog(@"putting on point for: %@", place);
        
        PlaceMark *placemark=[[PlaceMark alloc] initWithPlace:place];
        
        placemark.title = place.name;
        //placemark.subtitle = subTitle;
        [self.mapView addAnnotation:placemark];
        [placemark release];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [super objectLoader:objectLoader didLoadObjects:objects];
        
    if ( [(NSNumber*)objectLoader.userData intValue] == 80){
        if(self.segmentedControl.selectedSegmentIndex == 0){
            [self.spinnerView stopAnimating];
            self.spinnerView.hidden = true;
            [self mapPlaces];
        } 
        
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 81){        
        if(self.segmentedControl.selectedSegmentIndex == 1){
            [self.spinnerView stopAnimating];
            self.spinnerView.hidden = true;
            [self mapPlaces];
        } 
    }
    
}

- (void)dealloc{
    [_mapView release];
    [locationManager release];
    [spinnerView release];
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [super dealloc];
}


-(IBAction)reloadMap{
    //called on interaction for changing segment
    [FlurryAnalytics logEvent:@"MAP_VIEW" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"view", [NSString stringWithFormat:@"%i", self.segmentedControl.selectedSegmentIndex], nil]];
    [self mapPlaces];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D center = region.center;
    
    if (timer){
        //invalidate existing timer
        [timer invalidate];
        timer = nil;
    }
    
    CLLocationDegrees uLat = lastCoordinate.latitude;
    CLLocationDegrees uLng = lastCoordinate.longitude;
    
    CLLocationDegrees mLat = center.latitude;
    CLLocationDegrees mLng = center.longitude;
    
    //without dataLoaded, the first time this runs it will get a whole world map
    if ([self dataLoaded] && (fabs(uLat - mLat) > region.span.latitudeDelta/2 || fabs(uLng - mLng) > region.span.longitudeDelta/2 || region.span.latitudeDelta > 2.5*lastLatSpan) ){
        
        DLog(@"Reloading map contents for new co-ordinate");
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(loadContent)
                                       userInfo:nil
                                        repeats:NO];
    }    
}


-(IBAction)recenter{
    MKCoordinateRegion region;
    
	CLLocation *location = locationManager.location;
    region.center = location.coordinate;  
    
    MKCoordinateSpan span; 
    
    span.latitudeDelta  = 0.02; // default zoom
    span.longitudeDelta = 0.02; // default zoom
    
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)_annotation{
    
    if( [_annotation isKindOfClass:[PlaceMark class]] ){
        PlaceMark *annotation = _annotation;
        // try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"placeAnnotationIdentifier";
        
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)        
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (!pinView) {            
            // if an existing pin view was not available, create one
            pinView = [[[MKPinAnnotationView alloc]
                        initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
        } else {           
            pinView.annotation = annotation;            
        }
        pinView.canShowCallout = YES;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = [[self places] indexOfObjectIdenticalTo:annotation.place];
        [rightButton addTarget:self action:@selector(showPlaceDetails:) 
              forControlEvents:UIControlEventTouchUpInside];
        
        pinView.rightCalloutAccessoryView = rightButton;
        
        if (annotation.place.bookmarked){
            pinView.image = [UIImage imageNamed:@"MyMarker.png"];
        } else {
            pinView.image = [UIImage imageNamed:@"FriendMarker.png"];
        }
        return pinView;
    } else {
        return nil;
    }
}

- (void)showPlaceDetails:(UIButton*)sender{
    
    // the detail view does not want a toolbar so hide it
    Place* place = [[self places] objectAtIndex:sender.tag];    
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
    
    placePageViewController.place = place;
    
    [self.navigationController pushViewController:placePageViewController animated:YES];
    [placePageViewController release];
    
}


#pragma mark - loginController delegates
#pragma mark - Login delegate methods
- (void) loadContent {
    timer = nil;
    lastCoordinate = self.mapView.region.center;
    lastLatSpan = self.mapView.region.span.latitudeDelta;
    self.lat = [NSString stringWithFormat:@"%f",  lastCoordinate.latitude];
    self.lng = [NSString stringWithFormat:@"%f",  lastCoordinate.longitude];
    
    [self.spinnerView startAnimating];
    self.spinnerView.hidden = false;
    [super findNearbyPlaces];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [FlurryAnalytics logEvent:@"MAP_VIEW" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"view", [NSString stringWithFormat:@"%i", self.segmentedControl.selectedSegmentIndex], nil]];
    
    self.locationManager = [LocationManagerManager sharedCLLocationManager];
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
    self.spinnerView.hidden = true;
    [self recenter];
    
    lastCoordinate = self.mapView.region.center;
    lastLatSpan = self.mapView.region.span.latitudeDelta;
    
    UIImage *mapImage = [UIImage imageNamed:@"104-index-cards.png"];
    
    UIBarButtonItem *flipButton =  [[UIBarButtonItem alloc] initWithImage:mapImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleMapList)];
    self.navigationItem.rightBarButtonItem = flipButton;
    [flipButton release];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleToolBar:self.toolbar];
    [StyleHelper styleToolBar:self.bottomToolBar];
    
    if ([popularPlaces count] == 0 && [followingPlaces count] == 0){
        //if a set of places hasn't already been set, get them for current location
        [self loadContent];
    } else {
        [self mapPlaces];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Unregistered experience methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    }
}

@end
