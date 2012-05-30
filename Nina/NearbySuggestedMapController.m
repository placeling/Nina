//
//  NearbySuggestedMapController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+SBJSON.h"
#import "PerspectiveUserTableViewController.h"
#import "PerspectiveTagTableViewController.h"
#import "PerspectivePlaceMark.h"
#import "PlaceMark.h"
#import "Perspective.h"
#import "PlacePageViewController.h"
#import "LoginController.h"
#import "User.h"
#import "Place.h"
#import "NearbySuggestedPlaceController.h"
#import "NearbySuggestedMapController.h"
#import "FlurryAnalytics.h"
#import "NearbyPlacesViewController.h"
#import "UserManager.h"

@interface NearbySuggestedMapController (Private)
-(void)drawMapPlaces;
-(void)updateMapView;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
@end

@implementation NearbySuggestedMapController

@synthesize mapView=_mapView, spinnerView, place_id;
@synthesize locationManager, bottomToolBar, usernameButton,hashtagButton, placemarkButton;
@synthesize showTagsButton, showPeopleButton;

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
    
    if ( self.userFilter ){
        [nsController setUserFilter:self.userFilter];
    }
    if ( self.tagFilter ){
        [nsController setTagFilter:self.tagFilter];
    }
    
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


-(IBAction)showPeople{
    [usernameButton dismissAnimated:true];
    [FlurryAnalytics logEvent:@"QUICKPICK_USER_FILTER"];
    userFilter = nil;
    //reset the hiddenness based on tags
    
    NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
    NSSet *visiblePlacemarks = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    for ( PlaceMark *mark in visiblePlacemarks ){
        mark.tag = 0;
        for (Perspective *perspective in mark.place.placemarks){
            if (!tagFilter || [perspective.tags indexOfObject:tagFilter] != NSNotFound ){
                perspective.hidden = false;
                mark.tag = 1;
            } else {
                perspective.hidden = true;
            }
        }
        if (mark.tag == 1){
            [visiblePlaces addObject:mark.place];
            mark.place.hidden = false;
        } else {
            mark.place.hidden = true;
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

-(IBAction)changeTab{
    [placeSuperset removeAllObjects];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
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
        
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 83 ){
        [myPlaces removeAllObjects];
        for (Place* object in objects){
            object.placemarks = object.homePerspectives;
            [myPlaces addObject:object];
        }
        [self findNearbyPlaces];
    }
    
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
        userChild.places = visiblePlaces;
        [userChild refreshTable];
        [visiblePlaces release];
    }
    
    if (tagChild){
        NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
        NSSet *visiblePlacemarks = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
        for ( PlaceMark *mark in visiblePlacemarks ){
            [visiblePlaces addObject:mark.place];             
        }
        tagChild.places = visiblePlaces;
        [tagChild refreshTable];
        [visiblePlaces release];
    }
    
    
}

- (void)dealloc{
    [_mapView release];
    [locationManager release];
    [spinnerView release];
    [placemarkButton release];
    [placeSuperset release];
    [hashtagButton release];
    [showTagsButton release];
    [place_id release];
    [super dealloc];
}


-(IBAction)reloadMap{
    
    NSString *currentUser = [NinaHelper getUsername];
        
    if ( !currentUser && self.segmentedControl.selectedSegmentIndex != 2 ) {
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
    if ( (fabs(uLat - mLat) > region.span.latitudeDelta/2 || fabs(uLng - mLng) > region.span.longitudeDelta/2 || region.span.latitudeDelta > 2.5*lastLatSpan || region.span.latitudeDelta < lastLatSpan/2.5) ){
        
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


-(IBAction)showTags{
    [hashtagButton dismissAnimated:true];
    tagFilter = nil;
    [FlurryAnalytics logEvent:@"QUICKPICK_TAG_FILTER"];
    NSMutableArray *visiblePlaces = [[NSMutableArray alloc] init];
    NSSet *visiblePlacemarks = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    for ( PlaceMark *mark in visiblePlacemarks ){
        mark.tag = 0;        
        for (Perspective *perspective in mark.place.placemarks){
            if ( !userFilter || [perspective.user.username isEqualToString:userFilter] ){
                perspective.hidden = false;
                mark.tag =1;
            } else {
                perspective.hidden = true;
            }
        }
        if (mark.tag == 1){
            [visiblePlaces addObject:mark.place];
            mark.place.hidden = false;
        } else {
            mark.place.hidden = true;
        } 
    }
    
    PerspectiveTagTableViewController *tagController = [[PerspectiveTagTableViewController alloc] initWithPlaces:visiblePlaces];
    tagController.delegate = self;
    tagChild = tagController;
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:tagController];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [tagController release];
    [visiblePlaces release];
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
        annotation.tag = 0;
        
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
        pinView.image = [UIImage imageNamed:@"FriendMarker.png"];
        if ( tagFilter || userFilter ){
            pinView.hidden = true;
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


-(void)setUserFilter:(NSString*)username{
    
    userFilter = username;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self drawMapPlaces];
    
    if ( userFilter ){
        self.usernameButton = [[[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"%@", userFilter]]autorelease];
        self.usernameButton.backgroundColor = [UIColor colorWithRed:185/255.0 green:43/255.0 blue:52/255.0 alpha:1.0];
        self.usernameButton.delegate = self;
        [self.usernameButton presentPointingAtBarButtonItem:self.showPeopleButton animated:true];
    }
}

-(void)setTagFilter:(NSString*)hashTag{
    
    tagFilter = hashTag;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self drawMapPlaces];
    
    if ( tagFilter ){
        self.hashtagButton = [[[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"#%@", tagFilter]]autorelease];
        self.hashtagButton.backgroundColor = [UIColor colorWithRed:185/255.0 green:43/255.0 blue:52/255.0 alpha:1.0];
        self.hashtagButton.delegate = self;
        [self.hashtagButton presentPointingAtBarButtonItem:self.showTagsButton animated:true];
    }
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    if ( popTipView == self.hashtagButton ){
        tagFilter = nil;
    } else {
        userFilter = nil;
    }
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
    
    UIImage *mapImage = [UIImage imageNamed:@"listIcon.png"];
    
    UIBarButtonItem *flipButton =  [[UIBarButtonItem alloc] initWithImage:mapImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleMapList)];
    self.navigationItem.rightBarButtonItem = flipButton;
    [flipButton release];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleToolBar:self.toolbar];
    [StyleHelper styleToolBar:self.bottomToolBar];
    
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
        [objectManager loadObjectsAtResourcePath:requestUrl delegate:self block:^(RKObjectLoader* loader) {     
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
