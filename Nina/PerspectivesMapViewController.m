//
//  PerspectivesMapViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerspectivesMapViewController.h"

#import "NSString+SBJSON.h"
#import "PerspectivePlaceMark.h"
#import "PlaceMark.h"
#import "Perspective.h"
#import "PlacePageViewController.h"
#import "LoginController.h"
#import "UserManager.h"
#import "NearbySuggestedMapController.h"

@interface PerspectivesMapViewController (Private)
-(void)mapUserPlaces;
-(void)updateMapView;
-(IBAction)recenterHome;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
@end

@implementation PerspectivesMapViewController

@synthesize mapView=_mapView, toolbar, spinnerView, showMineButton;
@synthesize username=_username, user;
@synthesize nearbyMarks, userTime;
@synthesize locationManager;

- (id) initForUserName:(NSString *)username{
    if(self = [super init]){
        self.username = username;
        User *sharedUser = [UserManager sharedMeUser];
        if (sharedUser) {
            self.userTime = sharedUser.timestamp;
        }
	}
	return self;    
}

-(IBAction)showMine{
    
    NearbySuggestedMapController *myController = [[NearbySuggestedMapController alloc] init];
            
    myController.initialIndex = 0;
    myController.origin = self.mapView.region.center;
    
    [self.navigationController pushViewController:myController animated:YES];
    
    [myController release];
}

-(void)updateMapView{
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (Place *place in nearbyMarks){        
        DLog(@"putting on point for: %@", place);
               
        PlaceMark *placemark=[[PlaceMark alloc] initWithPlace:place];
        
        placemark.title = place.name;
        //placemark.subtitle = subTitle;
        [self.mapView addAnnotation:placemark];
        [placemark release];
    }
}

-(IBAction)recenterHome{
    MKCoordinateRegion region;
    
    region.center = self.user.homeLocation; 
    
    MKCoordinateSpan span = self.mapView.region.span;
    region.span = span;
    
    [self.mapView setRegion:region animated:false];
    
    [self refreshMap];
}

-(void)mapUserPlaces {
	CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    NSString *urlString = @"/v1/perspectives/nearby";		
    
    NSString* lat = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSString *span = [NSString stringWithFormat:@"%f", self.mapView.region.span.latitudeDelta];
    
    urlString = [NSString stringWithFormat:@"%@?lat=%@&lng=%@&span=%@", urlString, lat, lng, span];
    
    if (self.username != nil){
        urlString = [NSString stringWithFormat:@"%@&username=%@", urlString, self.username]; 
    }
    
    [self.spinnerView startAnimating];
    
    [objectManager loadObjectsAtResourcePath:urlString usingBlock:^(RKObjectLoader* loader) {
        loader.userData = [NSNumber numberWithInt:50];;
        loader.delegate = self;
    }];
    
}

- (void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [_mapView release];
    [_username release];
    [locationManager release];
    [nearbyMarks release];
    [toolbar release];
    [showMineButton release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D center = region.center;
    
    
    CLLocationDegrees uLat = lastCoordinate.latitude;
    CLLocationDegrees uLng = lastCoordinate.longitude;
    
    CLLocationDegrees mLat = center.latitude;
    CLLocationDegrees mLng = center.longitude;
    
    //without maploaded, the first time this runs it will get a whole world map
    if (mapLoaded && (fabs(uLat - mLat) > region.span.latitudeDelta/2 || fabs(uLng - mLng) > region.span.longitudeDelta/2 || region.span.latitudeDelta > 2.5*lastLatSpan) ){
        lastCoordinate = mapView.region.center;
        lastLatSpan = mapView.region.span.latitudeDelta;
        DLog(@"Reloading map contents for new co-ordinate");
        [self mapUserPlaces];
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

-(IBAction)refreshMap{
    [self mapUserPlaces];
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
        pinView.canShowCallout = YES;
        pinView.calloutOffset = CGPointMake(-7, 0);
        pinView.draggable = false;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = [nearbyMarks indexOfObjectIdenticalTo:annotation.place];
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
        
        pinView.centerOffset = CGPointMake(10, -20);
        return pinView;
    } else {
        return nil;
    }
}

- (void)showPlaceDetails:(UIButton*)sender{
    
    // the detail view does not want a toolbar so hide it
    Place* place = [nearbyMarks objectAtIndex:sender.tag];    
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
    
    if (user){
        placePageViewController.referrer = user.username;
    }
    
    placePageViewController.place = place;
    
    if ( ![self.user.username isEqualToString:[NinaHelper getUsername]] ){
        placePageViewController.initialSelectedIndex = [NSNumber numberWithInt:2];
        placePageViewController.referrer = self.user.username;
    }
        
    [self.navigationController pushViewController:placePageViewController animated:YES];
    [placePageViewController release];
    
}


#pragma mark RKObjectLoader

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    [self.spinnerView stopAnimating];
    DLog(@"Encountered an error: %@", error);
}



- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [self.spinnerView stopAnimating];
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 50 ){
        for (Place* place in objects){
            BOOL found = false;
            for (Place *existing in nearbyMarks){
                if ( [place.pid isEqualToString:existing.pid] ){
                    found = true; //already exists
                }
            }
            
            if (!found){
                [nearbyMarks addObject:place];
            }
        }        
        
        [self updateMapView];        
    }
}


#pragma mark - loginController delegates
- (void)loadContent {
    NSString *currentUser = [NinaHelper getUsername];
    mapLoaded = true;
    
    if ((currentUser || currentUser.length > 0) && (!self.username || self.username.length == 0)) {
        self.username = currentUser;
    }
    lastCoordinate = self.mapView.region.center;
    lastLatSpan = self.mapView.region.span.latitudeDelta;
    
    if (!self.username || self.username.length == 0) {
        self.navigationItem.title = @"Your Map";
        
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in to bookmark locations and create your own map";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        
        [baseAlert show];
        [baseAlert release];
    } else {
        self.navigationItem.title = self.username;
        [self mapUserPlaces];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    mapLoaded = false;
    // Do any additional setup after loading the view from its nib.
    //[self.mapView.userLocation addObserver:self  
    //                            forKeyPath:@"location"
    //                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
    //                           context:NULL];
    self.locationManager = [LocationManagerManager sharedCLLocationManager];
    nearbyMarks = [[NSMutableArray alloc] init];
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
    self.spinnerView.hidden = true;
    [self recenter];
    [self loadContent];
    
    User *currentUser = [UserManager sharedMeUser];
    
    if ( currentUser && currentUser.userId != self.user.userId ){
        self.showMineButton.enabled = true;
    } else {
        self.showMineButton.enabled = false;
    }
    
    
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"53-house.png"] style:UIBarButtonItemStylePlain target:self action:@selector(recenterHome) ];    
    self.navigationItem.rightBarButtonItem = modalButton;
    [modalButton release];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleToolBar:self.toolbar];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    User *sharedUser = [UserManager sharedMeUser];
    if ( sharedUser && sharedUser.timestamp  > self.userTime ){
        self.userTime = sharedUser.timestamp;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [nearbyMarks removeAllObjects]; 
        [self loadContent];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

