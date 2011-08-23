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

@interface PerspectivesMapViewController (Private)
-(void)mapUserPlaces;
-(void)updateMapView;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
@end

@implementation PerspectivesMapViewController

@synthesize mapView;
@synthesize userName;
@synthesize nearbyMarks;
@synthesize locationManager;

-(void)updateMapView{    
    for (Place *place in nearbyMarks){        
        DLog(@"putting on point for: %@", place);
               
        PlaceMark *placemark=[[PlaceMark alloc] initWithPlace:place];
        
        placemark.title = place.name;
        //placemark.subtitle = subTitle;
        [mapView addAnnotation:placemark];
    }
}

-(void)mapUserPlaces {
	CLLocation *location = locationManager.location;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/perspectives/nearby", [NinaHelper getHostname]];		
    
    NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    NSString *span = [NSString stringWithFormat:@"%f", self.mapView.region.span.latitudeDelta];
    
    urlString = [NSString stringWithFormat:@"%@?lat=%@&long=%@&span=%@", urlString, lat, lng, span];
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    
    [request setDelegate:self];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];
    
}

- (void)dealloc{
    [mapView release];
    [userName release];
    [locationManager release];
    [nearbyMarks release];
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
    
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)_annotation{
    PlaceMark *annotation = _annotation;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"placeAnnotationIdentifier";
    
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)        
    [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
    if (!pinView) {            
        // if an existing pin view was not available, create one
        MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
        
        customPinView.pinColor = MKPinAnnotationColorPurple;            
        customPinView.animatesDrop = YES;            
        customPinView.canShowCallout = YES;
        
        if( [annotation isKindOfClass:[PlaceMark class]] ){
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightButton.tag = [nearbyMarks indexOfObjectIdenticalTo:annotation.place];
            [rightButton addTarget:self action:@selector(showPlaceDetails:) 
                  forControlEvents:UIControlEventTouchUpInside];
            
            customPinView.rightCalloutAccessoryView = rightButton;

        }
        return customPinView;
        
    } else {           
        pinView.annotation = annotation;            
    }
    
    return pinView;

}

- (void)showPlaceDetails:(UIButton*)sender{
    
    // the detail view does not want a toolbar so hide it
    Place* place = [nearbyMarks objectAtIndex:sender.tag];    
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
    
    placePageViewController.place = place;
        
    [self.navigationController pushViewController:placePageViewController animated:YES];
    
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching binary data
	int statusCode = [request responseStatusCode];
	if (200 != statusCode){
        [NinaHelper handleBadRequest:request  sender:self];
	} else {
		NSData *data = [request responseData];
        
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
		[nearbyMarks release];
        NSArray *rawPlaces = [[jsonString JSONValue] objectForKey:@"places"];
        nearbyMarks = [[NSMutableArray alloc] initWithCapacity:[rawPlaces count]];
        
        for (NSDictionary* dict in rawPlaces){
            Place* place = [[Place alloc] initFromJsonDict:dict];
            [nearbyMarks addObject:place]; 
            [place release];
        }
        
        [self updateMapView];
        [self recenter];
	}
    
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self mapUserPlaces];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    //[self.mapView.userLocation addObserver:self  
    //                            forKeyPath:@"location"
    //                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
    //                           context:NULL];
    self.locationManager = [[LocationManagerManager sharedCLLocationManager] retain];
    
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
    [self recenter];
}

- (void)viewDidUnload{
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

