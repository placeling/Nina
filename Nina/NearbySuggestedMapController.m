//
//  NearbySuggestedMapController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SBJSON.h"
#import "PerspectivePlaceMark.h"
#import "PlaceMark.h"
#import "Perspective.h"
#import "PlacePageViewController.h"
#import "LoginController.h"
#import "User.h"
#import "Place.h"
#import "NearbySuggestedPlaceController.h"
#import "NearbySuggestedMapController.h"
#import "NearbyPlacesViewController.h"
#import "PerspectiveUserTableViewController.h"
#import "PerspectiveTagTableViewController.h"
#import "UserManager.h"
#import "FlurryAnalytics.h"

@interface NearbySuggestedMapController (Private)
-(void)drawMapPlaces;
-(void)updateMapView;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
-(void)showHelperPopup;
@end

@implementation NearbySuggestedMapController

@synthesize mapView=_mapView, spinnerView, place_id, locationManager, placemarkButton;

-(IBAction)toggleMapList{
    NearbySuggestedPlaceController *nsController = [[NearbySuggestedPlaceController alloc] init];        
    
    nsController.myPlaces = self.myPlaces;
    nsController.followingPlaces = self.followingPlaces;
    nsController.popularPlaces = self.popularPlaces;
    nsController.category = self.category;
    nsController.searchTerm = self.searchTerm;
    nsController.initialIndex = self.segmentedControl.selectedSegmentIndex;
    nsController.navTitle = self.navTitle;
    
    nsController.popularLoaded = self.popularLoaded;
    nsController.myLoaded = self.myLoaded;
    nsController.followingLoaded = self.followingLoaded;
    
    nsController.ad = self.ad;
    nsController.latitudeDelta = self.latitudeDelta;
    nsController.origin = self.origin;
    nsController.quickpick = self.quickpick;
    
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
    [nsController release];
    
    if ( self.userFilter ){
        [nsController setUserFilter:self.userFilter];
    }
    if ( self.tagFilter ){
        [nsController setTagFilter:self.tagFilter];
    }
}

-(IBAction)showNearbyPlaces{
    NearbyPlacesViewController *nearbyController = [[NearbyPlacesViewController alloc] init];
    
    nearbyController.hardLocation = [[[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude: self.mapView.centerCoordinate.longitude] autorelease];
    
    CLLocationCoordinate2D coord = self.mapView.centerCoordinate;
    float ldelta = self.mapView.region.span.latitudeDelta;
    
    CLLocation *loc = [[[CLLocation alloc] initWithLatitude:coord.latitude + ldelta longitude:coord.longitude] autorelease];
    CLLocation *loc2 = [[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude] autorelease];
    
    nearbyController.hardAccuracy = [NSNumber numberWithFloat:[loc distanceFromLocation:loc2]/2.0];
    
    [self.navigationController pushViewController:nearbyController animated:TRUE];
    
    [nearbyController release];
}



-(IBAction)changeTab{
    [placeSuperset removeAllObjects];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self setUserFilter:nil];
    [self.usernameButton dismissAnimated:true];
    
    [self reloadMap];
}


-(void)drawMapPlaces{    
    //[self.mapView removeAnnotations:self.mapView.annotations];
    
    NSArray *existing = self.mapView.annotations;
    NSMutableArray *toAdd = [[NSMutableArray alloc] initWithArray:placeSuperset];
    
    for ( PlaceMark *mark in existing ){
        if ( ![mark isKindOfClass:[PlaceMark class]] ){
            //at least one annotation is actually the user location
            continue;
        }
        
        for (Place *place in placeSuperset){
            if ( [place.pid isEqualToString:mark.place.pid] ){
                [toAdd removeObject:place];
                break;
            }
        }
    }
    
    for (Place *place in toAdd){        
        DLog(@"putting on point for: %@", place.name);
        
        PlaceMark *placemark=[[PlaceMark alloc] initWithPlace:place];
        [self.mapView addAnnotation:placemark];
        
        [placemark release];
        
        if ( self.place_id && [place.pid isEqualToString:self.place_id] ){
            [self.mapView selectAnnotation:placemark animated:FALSE];
            CLLocationCoordinate2D coord;
            coord.latitude = [place.lat floatValue];
            coord.longitude = [place.lng floatValue];
            self.mapView.centerCoordinate = coord;
            
            self.place_id = nil;
        }
    }
    [toAdd release];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [super objectLoader:objectLoader didLoadObjects:objects];
    
    for ( Place *place in [self places] ){
        bool found = false;
        for ( Place *sPlace in placeSuperset ){
            if ( [sPlace.pid isEqualToString:place.pid] ){
                found = true;
                break;
            }
        }
        
        if (!found){
            [placeSuperset addObject:place];
        }
    }
    
    [self.spinnerView stopAnimating];
    self.spinnerView.hidden = true;
    [self drawMapPlaces];
    
    if (userChild){
        NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
        NSSet *visiblePlacemarks = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
        for ( PlaceMark *mark in visiblePlacemarks ){
            [visiblePlaces addObject:mark.place];             
        }
        [userChild setPlaces:visiblePlaces];
        [userChild refreshTable];
        [visiblePlaces release];
    }
    
    if (tagChild){
        NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
        NSSet *visiblePlacemarks = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
        for ( PlaceMark *mark in visiblePlacemarks ){
            [visiblePlaces addObject:mark.place];             
        }
        [tagChild setPlaces:visiblePlaces];
        [tagChild refreshTable];
        [visiblePlaces release];
    }
    
    NSString *currentUser = [NinaHelper getUsername];    
    if ( self.segmentedControl.selectedSegmentIndex == 0 && currentUser){
        [self showHelperPopup];
    }
    
}

-(NSMutableArray*)visiblePlaces{
    NSMutableArray *visPlaces = [[[NSMutableArray alloc] init] autorelease];
    
    for (PlaceMark *placeMark in [self.mapView annotationsInMapRect:self.mapView.visibleMapRect] ){
        [visPlaces addObject:placeMark.place];
        
    }
    return visPlaces;
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [super objectLoader:objectLoader didFailWithError:error];
    [self.spinnerView stopAnimating];
    self.spinnerView.hidden = true;
}

- (void)dealloc{
    [_mapView release];
    [locationManager release];
    [spinnerView release];
    [placemarkButton release];
    [placeSuperset release];
    [place_id release];
    [super dealloc];
}


-(IBAction)reloadMap{
    
    NSString *currentUser = [NinaHelper getUsername];
        
    if ( !currentUser && self.segmentedControl.selectedSegmentIndex != 2 && !shownPopup ) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        UIAlertView *baseAlert;
        NSString *alertMessage;
        if ( self.segmentedControl.selectedSegmentIndex == 0 ){
            alertMessage = @"Sign up or log in to see your\nplacemarks on this map";
        } else {
            alertMessage = @"Sign up or log in to see the places\nthat people you follow love";
        }
        
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0;
        
        [baseAlert show];
        [baseAlert release];
        shownPopup = true;
    } else {
        //called on interaction for changing segment
        [FlurryAnalytics logEvent:@"MAP_VIEW" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"view", [NSString stringWithFormat:@"%i", self.segmentedControl.selectedSegmentIndex], nil]];

        if ( self.segmentedControl.selectedSegmentIndex == 0 && !self.myLoaded ){
            [self.spinnerView startAnimating];
            self.spinnerView.hidden = false;
            [super findNearbyPlaces];
        } else if ( self.segmentedControl.selectedSegmentIndex == 1 && !self.followingLoaded ){
            [self.spinnerView startAnimating];
            self.spinnerView.hidden = false;
            [super findNearbyPlaces];
        } else if ( self.segmentedControl.selectedSegmentIndex == 2 && !self.popularLoaded ){
            [self.spinnerView startAnimating];
            self.spinnerView.hidden = false;
            [super findNearbyPlaces];
        } else {
            [placeSuperset addObjectsFromArray:[self places]];
        }
        [self drawMapPlaces];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D center = region.center;
    
    if ( viewLoaded ){
        self.latitudeDelta = region.span.latitudeDelta;
        self.origin = center;
    }
    if (region.span.latitudeDelta > 0.0015){
        self.placemarkButton.hidden = true;
    } else {
        self.placemarkButton.hidden = false;
    }
    
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
    if ( (fabs(uLat - mLat) > region.span.latitudeDelta/4 || fabs(uLng - mLng) > region.span.longitudeDelta/4 || region.span.latitudeDelta > 2.5*lastLatSpan || region.span.latitudeDelta < lastLatSpan/2.5) ){
        
        if ( viewLoaded ){        

            self.myLoaded = false;
            self.followingLoaded = false;
            self.popularLoaded = false;
            
            [self.spinnerView stopAnimating];
            self.spinnerView.hidden = true;
            [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
            DLog(@"Reloading map contents for new co-ordinate");
        
            timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(loadContent)
                                       userInfo:nil
                                        repeats:NO];
        }
    }    
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)_annotation{
    
    if( [_annotation isKindOfClass:[PlaceMark class]] ){
        PlaceMark *annotation = _annotation;
        // try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"placeAnnotationIdentifier";
        
        MKAnnotationView* pinView = (MKAnnotationView *)        
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (!pinView) {            
            // if an existing pin view was not available, create one
            pinView = [[[MKAnnotationView alloc]
                        initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
        } else {           
            pinView.annotation = annotation;            
        }
        pinView.hidden = false;
        pinView.enabled = true;
        pinView.canShowCallout = YES;
        pinView.calloutOffset = CGPointMake(-7, 0);
        pinView.centerOffset = CGPointMake(10, -20);
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = [placeSuperset indexOfObjectIdenticalTo:annotation.place];
        [rightButton addTarget:self action:@selector(showPlaceDetails:) 
              forControlEvents:UIControlEventTouchUpInside];
        
        pinView.rightCalloutAccessoryView = rightButton;
        if (annotation.place.bookmarked){
            if ( annotation.place.highlighted ) {
                pinView.image = [UIImage imageNamed:@"HilightMarker.png"];
            } else {
                pinView.image = [UIImage imageNamed:@"MyMarker.png"];
            }
        } else {
            pinView.image = [UIImage imageNamed:@"FriendMarker.png"];
        }
        
        if ( userFilter || tagFilter){
            annotation.tag = 0;
        }else {
            annotation.tag = 1;
        }
        
        for (Perspective *perspective in annotation.place.placemarks){
            if ( (!userFilter || [perspective.user.username isEqualToString:userFilter]) && (!tagFilter || [perspective.tags indexOfObject:tagFilter] != NSNotFound ) ){
                pinView.tag =1;
                annotation.tag =1;
                perspective.hidden = false;
            } else {
                perspective.hidden = true;
            }
        }
        
        if (annotation.tag == 1){
            annotation.place.hidden = false;
        } else {
            annotation.place.hidden = true;
        }
        
        if (annotation.tag == 1){
            return pinView;
        }
        
        if ( tagFilter || userFilter ){
            pinView.hidden = true;
            pinView.enabled = false;
        }
        pinView.tag = 0;
        annotation.tag = 0;
        return pinView;

    } else {
        return nil;
    }
}

- (void)showPlaceDetails:(UIButton*)sender{
    DLog(@"Showing place details for button tag: %i", sender.tag);
    // the detail view does not want a toolbar so hide it
    Place* place = [placeSuperset objectAtIndex:sender.tag];    
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
    
    placePageViewController.place = place;
    placePageViewController.initialSelectedIndex = [NSNumber numberWithInt:self.segmentedControl.selectedSegmentIndex];
    
    if (place.google_ref){
        placePageViewController.google_ref = place.google_ref;
    }
    
    if ( !place.perspectiveCount || place.perspectiveCount == 0){
        placePageViewController.initialSelectedIndex = [NSNumber numberWithInt:0];
    }
    
    [self.navigationController pushViewController:placePageViewController animated:YES];
    [placePageViewController release];
    
}


// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [super popTipViewWasDismissedByUser:popTipView];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self drawMapPlaces];
}


#pragma mark - loginController delegates
#pragma mark - Login delegate methods
- (void) loadContent {
    timer = nil;
    
    self.myLoaded = false;
    self.followingLoaded = false;
    
    lastCoordinate = self.mapView.region.center;
    lastLatSpan = self.mapView.region.span.latitudeDelta;
    self.origin = lastCoordinate;
    
    [self reloadMap];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [FlurryAnalytics logEvent:@"MAP_VIEW" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"view", [NSString stringWithFormat:@"%i", self.segmentedControl.selectedSegmentIndex], nil]];
    
    self.locationManager = [LocationManagerManager sharedCLLocationManager];
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
    
    self.spinnerView.hidden = true;
    
    self.placemarkButton.hidden = true;
    viewLoaded = false;
    MKCoordinateRegion region = self.mapView.region;
    
	CLLocation *location = locationManager.location;
    region.center = location.coordinate;  
    
    [self.mapView setRegion:region animated:YES];
    
    lastCoordinate = self.mapView.region.center;
    lastLatSpan = self.mapView.region.span.latitudeDelta;
    
    placeSuperset = [[NSMutableArray alloc] init];
    
    [placeSuperset addObjectsFromArray: [self places]];
    
    if ( quickpick ){
        [self.mapView setFrame:CGRectMake(self.toolbar.frame.origin.x, self.toolbar.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height + self.toolbar.frame.size.height)];
        self.toolbar.hidden = true;
        self.segmentedControl.enabled = false;        
    }
    
    UIImage *mapImage = [UIImage imageNamed:@"listIcon.png"];
    
    UIBarButtonItem *flipButton =  [[UIBarButtonItem alloc] initWithImage:mapImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleMapList)];
    self.navigationItem.rightBarButtonItem = flipButton;
    [flipButton release];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleToolBar:self.toolbar];
    
    MKCoordinateRegion region = self.mapView.region;
    CLLocation *location = locationManager.location;    
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    if ( origin.latitude == 0.0 && origin.longitude == 0.0 ){
        region.center = location.coordinate;  
    } else {
        region.center = self.origin;
    }
    
    MKCoordinateSpan span; 
    userChild = nil;
    tagChild = nil;
    
    span.latitudeDelta  = self.latitudeDelta;
    span.longitudeDelta  = self.latitudeDelta;

    region.span = span;
    
    viewLoaded = false;
    
    [self.mapView setRegion:region animated:YES];
    
    if ( self.place_id ){
        NSString *requestUrl = [NSString stringWithFormat:@"/v1/places/%@", self.place_id];
        [objectManager loadObjectsAtResourcePath:requestUrl  usingBlock:^(RKObjectLoader* loader) {
            loader.delegate = self;
            loader.objectMapping = [Place getObjectMapping];
            loader.userData = [NSNumber numberWithInt:83];
        }];
    
    } else {    
        if ( ![self dataLoaded] ){
            //if a set of places hasn't already been set, get them for current location
            [self loadContent];
        } else {
            User *user = [UserManager sharedMeUser];
            if ( user && user.timestamp  > self.userTime ){
                self.userTime = user.timestamp;
                [self.mapView removeAnnotations:self.mapView.annotations];
                [placeSuperset removeAllObjects];
                [self loadContent];
            } else {
                [self drawMapPlaces];
            }
        }
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    viewLoaded = true;    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setTagFilter:(NSString*)hashTag{
    [super setTagFilter:hashTag];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self drawMapPlaces];
}

-(void)setUserFilter:(NSString*)username{
    [super setUserFilter:username];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self drawMapPlaces];
}

#pragma mark - Unregistered experience methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0 && buttonIndex == 1) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    } else if (alertView.tag == 1 && buttonIndex == 1){
        NearbyPlacesViewController *nearbyPlacesViewController = [[NearbyPlacesViewController alloc] init];
        [self.navigationController pushViewController:nearbyPlacesViewController animated:YES];
        [nearbyPlacesViewController release];
    }
}

-(void)showHelperPopup{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    User *user = [UserManager sharedMeUser];
    if ( (![defaults objectForKey:@"map_add_place_tip"] || [defaults objectForKey:@"map_add_place_tip"] == false) && [self.myPlaces count] ==0 && (!user || [user.placeCount intValue] ==0) ){ 
        
        UIAlertView *baseAlert;
        NSString *alertMessage = @"You haven't yet added a place to your map. Add one now?";
        
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 1;
        
        [baseAlert show];
        [baseAlert release];
    }
    [defaults setObject:[NSNumber numberWithBool:true] forKey:@"map_add_place_tip"];
    [defaults synchronize];
}


@end
