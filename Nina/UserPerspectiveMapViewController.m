//
//  UserPerspectiveMapViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserPerspectiveMapViewController.h"
#import "NSString+SBJSON.h"
#import "PerspectivePlaceMark.h"
#import "Perspective.h"


@interface UserPerspectiveMapViewController (Private)
-(void)mapUserPlaces;
-(void)updateMapView;
-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array;
@end

@implementation UserPerspectiveMapViewController

@synthesize mapView;
@synthesize userName;
@synthesize nearbyMarks;
@synthesize locationManager;

-(void)updateMapView{
    
    for (Perspective *perspective in nearbyMarks){
        
        CLLocationCoordinate2D coordinate;
        DLog(@"putting on point for: %@", perspective);
        
        coordinate = perspective.place.location.coordinate;        
        PerspectivePlaceMark *placemark=[[PerspectivePlaceMark alloc] initWithCoordinate:coordinate];
        
        placemark.title = perspective.place.name;
        //placemark.subtitle = subTitle;
        [mapView addAnnotation:placemark];
    }
    
    
}

-(void)mapUserPlaces {
	CLLocation *location = locationManager.location;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/users/%@/perspectives", [NinaHelper getHostname], self.userName];		
    
    NSString* x = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* y = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
    NSString *radius = [NSString stringWithFormat:@"%f", accuracy];
    
    urlString = [NSString stringWithFormat:@"%@?x=%@&y=%@&radius=%@", urlString, x, y, radius];
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(Perspective*)closestPoint:(CLLocation*)referenceLocation fromArray:(NSArray*)array{
    
    NSInteger minDist = NSIntegerMax;
    Perspective* closest;
    
    for (Perspective *perspective in array){
        if ([perspective.place.location distanceFromLocation:referenceLocation] < minDist){
            closest = perspective;
            minDist = [perspective.place.location distanceFromLocation:referenceLocation];
        }
    }
    
    return closest;
}

-(IBAction)recenter{
    MKCoordinateRegion region;
    
	CLLocation *location = locationManager.location;
    region.center = location.coordinate;  
    
    MKCoordinateSpan span; 
    Perspective* closest = [self closestPoint:location fromArray:nearbyMarks];
    
    if (closest){
        CLLocationDistance distance = [closest.place.location distanceFromLocation:location];
        span.latitudeDelta = (6 * distance) / 111209;
    } else {
        span.latitudeDelta  = 0.1; // default zoom
    }
    
    
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
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
        NSArray *rawPerspectives = [[jsonString JSONValue] objectForKey:@"perspectives"];
        nearbyMarks = [[NSMutableArray alloc] initWithCapacity:[rawPerspectives count]];
        
        for (NSDictionary* dict in rawPerspectives){
            Perspective* newPerspective = [[Perspective alloc] initFromJsonDict:dict];
            [nearbyMarks addObject:newPerspective]; 
            [newPerspective release];
        }
        
        [self updateMapView];
        [self recenter];
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
        
    self.mapView.showsUserLocation = TRUE;
    self.locationManager = [[LocationManagerManager sharedCLLocationManager] retain];
    
    [self mapUserPlaces];
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
