//
//  SinglePlaceMapView.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SinglePlaceMapView.h"


@implementation SinglePlaceMapView

@synthesize mapView, place=_place, toolbar;

- (id)initWithPlace:(Place *)place{
    self = [super init];
    if (self) {
        self.place = place;
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
    [mapView release];
    [_place release];
    [toolbar release];
    [super dealloc];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)_annotation{
    PlaceMark *annotation = _annotation;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"placeAnnotationIdentifier";

    MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                           initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
    customPinView.canShowCallout = YES;
    
    if( [annotation isKindOfClass:[PlaceMark class]] ){
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(spawnMapApp) 
              forControlEvents:UIControlEventTouchUpInside];
        
        //customPinView.rightCalloutAccessoryView = rightButton;
        
        if (annotation.place.bookmarked){
            if ( annotation.place.highlighted ) {
                customPinView.image = [UIImage imageNamed:@"HilightMarker.png"];
            } else {
                customPinView.image = [UIImage imageNamed:@"MyMarker.png"];
            }
        } else {
            customPinView.image = [UIImage imageNamed:@"FriendMarker.png"];
        }
        return customPinView;
    }else {
        return nil;
    }
    
}

-(IBAction) spawnMapApp{
    NSString *currentLocation = @"Current+Location";
    CLLocationCoordinate2D destination = self.place.location.coordinate;        
    //saddr=%1.6f,%1.6f&   start.latitude, start.longitude
    NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%@&daddr=%1.6f,%1.6f", currentLocation, destination.latitude, destination.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    PlaceMark *placemark=[[PlaceMark alloc] initWithPlace:self.place];
    
    placemark.title = self.place.name;
    //placemark.subtitle = subTitle;
    [mapView addAnnotation:placemark];
    [placemark release];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = TRUE;
    
    MKCoordinateRegion region;
    CLLocation *location = self.place.location;
    
    region.center = location.coordinate;  
    
    MKCoordinateSpan span; 
    
    span.latitudeDelta  = 0.02; // default zoom
    span.longitudeDelta = 0.02; // default zoom
    
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
    
    //pre-opens callout   
    [self.mapView selectAnnotation:[mapView.annotations objectAtIndex:0] animated:FALSE];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [StyleHelper styleToolBar:toolbar];
    
    [super viewWillAppear:animated];
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

@end
