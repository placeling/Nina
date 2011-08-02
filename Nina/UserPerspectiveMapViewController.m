//
//  UserPerspectiveMapViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserPerspectiveMapViewController.h"
#import "NSString+SBJSON.h"
#import "NinaHelper.h"
#import "PerspectivePlaceMark.h"


@interface UserPerspectiveMapViewController (Private)
-(void)mapUserPlaces;
-(void)updateMapView;
@end

@implementation UserPerspectiveMapViewController

@synthesize mapView;
@synthesize userName;
@synthesize nearbyPlaces;
@synthesize locationManager;

-(void)updateMapView{
    
    for (NSDictionary *place in nearbyPlaces){
        
        CLLocationCoordinate2D coordinate;
        DLog(@"putting on point for: %@", place);
        
        coordinate.latitude = [[[place objectForKey:@"place_location"] objectAtIndex:0] doubleValue];
        coordinate.longitude = [[[place objectForKey:@"place_location"] objectAtIndex:1] doubleValue];
        
        PerspectivePlaceMark *placemark=[[PerspectivePlaceMark alloc] initWithCoordinate:coordinate];
        
        NSString *title = [[place objectForKey:@"place"] objectForKey:@"name"];;
        NSString *subTitle = [place objectForKey:@"memo"];
        
        placemark.title = title;
        placemark.subtitle = subTitle;
        [mapView addAnnotation:placemark];
    }
    
    
}

-(void)mapUserPlaces {
	//NSDate *now = [NSDate date];
	CLLocation *location = locationManager.location;
    
	if (location != nil){ //[now timeIntervalSinceDate:location.timestamp] < (60 * 5)){
		NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
		NSString *urlString = [NSString stringWithFormat:@"%@/users/%@/perspectives", [plistData objectForKey:@"server_url"], self.userName];		
        
		NSString* x = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
		NSString* y = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
		float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
		accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
        NSString *radius = [NSString stringWithFormat:@"%f", accuracy];
        
        urlString = [NSString stringWithFormat:@"%@?x=%@&y=%@&radius=%@", urlString, x, y, radius];
        NSURL *url = [NSURL URLWithString:urlString];
        
        
		ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        
		[request setDelegate:self];
		[request startAsynchronous];
	} else {
        needLocationUpdate = true;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    needLocationUpdate = FALSE;
    return self;
}

- (void)dealloc{
    [mapView release];
    [userName release];
    [nearbyPlaces release];
    [locationManager release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark location manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

    CLLocationCoordinate2D coord = newLocation.coordinate;
    MKCoordinateSpan span = {latitudeDelta: 1, longitudeDelta: 1};
    MKCoordinateRegion region = {coord, span};
    [mapView setRegion:region];
    
    if (needLocationUpdate){
        needLocationUpdate = false;
        [self mapUserPlaces];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath  
                     ofObject:(id)object  
                       change:(NSDictionary *)change  
                      context:(void *)context {  
    
    //if ([self.mapView isUserLocationVisible]) { 
    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.coordinate;  
    
    MKCoordinateSpan span; 
    span.latitudeDelta  = 1; // Change these values to change the zoom
    span.longitudeDelta = 1; 
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching binary data
	int statusCode = [request responseStatusCode];
	if (200 != statusCode){
        [NinaHelper handleBadRequest:request];
	} else {
		NSData *data = [request responseData];
        
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
		[nearbyPlaces release];
		nearbyPlaces = [[[jsonString JSONValue] objectForKey:@"perspectives"] retain];

		[jsonString release];
        
        [self updateMapView];
	}
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ( userName == nil || [userName isEqualToString:@""]){
        userName = @"tyler";
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    // Do any additional setup after loading the view from its nib.
    [self.mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                   context:NULL];
        
    [self mapUserPlaces];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
