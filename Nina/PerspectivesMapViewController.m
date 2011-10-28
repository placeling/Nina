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

@interface PerspectivesMapViewController (Private)
-(void)mapUserPlaces;
-(void)updateMapView;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
@end

@implementation PerspectivesMapViewController

@synthesize mapView, toolbar;
@synthesize username=_username, user;
@synthesize nearbyMarks;
@synthesize locationManager;

- (id) initForUserName:(NSString *)username{
    if(self = [super init]){
        self.username = username;
	}
	return self;    
}

-(void)updateMapView{    
    for (Place *place in nearbyMarks){        
        DLog(@"putting on point for: %@", place);
               
        PlaceMark *placemark=[[PlaceMark alloc] initWithPlace:place];
        
        placemark.title = place.name;
        //placemark.subtitle = subTitle;
        [mapView addAnnotation:placemark];
        [placemark release];
    }
}

-(void)mapUserPlaces {
	CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/perspectives/nearby", [NinaHelper getHostname]];		
    
    NSString* lat = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSString *span = [NSString stringWithFormat:@"%f", self.mapView.region.span.latitudeDelta];
    
    urlString = [NSString stringWithFormat:@"%@?lat=%@&long=%@&span=%@", urlString, lat, lng, span];
    
    if (self.username != nil){
        urlString = [NSString stringWithFormat:@"%@&username=%@", urlString, self.username]; 
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    
    [request setDelegate:self];
    [request setTag:50];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];
    
}

- (void)dealloc{
    //[self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    [NinaHelper clearActiveRequests:50];
    [mapView release];
    [_username release];
    [locationManager release];
    [nearbyMarks release];
    [toolbar release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
        
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)        
        [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];

        if (!pinView) {            
            // if an existing pin view was not available, create one
            pinView = [[[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
        } else {           
            pinView.annotation = annotation;            
        }
        pinView.canShowCallout = YES;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = [nearbyMarks indexOfObjectIdenticalTo:annotation.place];
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
    Place* place = [nearbyMarks objectAtIndex:sender.tag];    
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
    
    if (user){
        placePageViewController.referrer = user;
    }
    
    placePageViewController.place = place;
        
    [self.navigationController pushViewController:placePageViewController animated:YES];
    [placePageViewController release];
    
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching binary data
	int statusCode = [request responseStatusCode];
	if (200 != statusCode) {
        [NinaHelper handleBadRequest:request  sender:self];
    } else {
        // Store incoming data into a string
		NSString *jsonString = [request responseString];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
        NSArray *rawPlaces = [[jsonString JSONValue] objectForKey:@"places"];
        
        for (NSDictionary* dict in rawPlaces){
            
            BOOL found = false;
            for (Place *place in nearbyMarks){
                if ([[dict objectForKey:@"_id"] isEqualToString:place.pid]){
                    found = true; //already exists
                }
            }
            
            if (!found){
                Place* place = [[Place alloc] initFromJsonDict:dict];
                [nearbyMarks addObject:place]; 
                [place release];
            }
        }
        
        [self updateMapView];
	}
}

#pragma mark - loginController delegates
- (void)loadContent {
    NSString *currentUser = [NinaHelper getUsername];
    
    if ((currentUser || currentUser.length > 0) && (!self.username || self.username.length == 0)) {
        self.username = currentUser;
    }
    
    if (!self.username || self.username.length == 0) {
        self.navigationItem.title = @"Your Map";
        
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in and when you bookmark locations, they'll appear on this map";
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
    
    // Do any additional setup after loading the view from its nib.
    //[self.mapView.userLocation addObserver:self  
    //                            forKeyPath:@"location"
    //                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
    //                           context:NULL];
    self.locationManager = [LocationManagerManager sharedCLLocationManager];
    nearbyMarks = [[NSMutableArray alloc] init];
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
    [self recenter];
    
    [self loadContent];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [StyleHelper styleToolBar:self.toolbar];
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

