//
//  SinglePlaceMapView.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SinglePlaceMapView.h"


@implementation SinglePlaceMapView

@synthesize mapView, place=_place;

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
    [super dealloc];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)_annotation{
    PlaceMark *annotation = _annotation;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"placeAnnotationIdentifier";
    
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)        
    [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
            
    MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                           initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
    
    customPinView.pinColor = MKPinAnnotationColorPurple;            
    customPinView.animatesDrop = YES;            
    customPinView.canShowCallout = YES;
    
    if( [annotation isKindOfClass:[PlaceMark class]] ){
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(spawnMapApp) 
              forControlEvents:UIControlEventTouchUpInside];
        
        customPinView.rightCalloutAccessoryView = rightButton;
        
    }
    return customPinView;
        
    
    return pinView;
    
}

-(IBAction) spawnMapApp{
    UIApplication *app = [UIApplication sharedApplication];
    NSString *queryString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&near=%@", self.place.name, [NSString stringWithFormat:@"%f,%f", self.place.location.coordinate.latitude , self.place.location.coordinate.longitude]];
    [app openURL:[[[NSURL alloc] initWithString: queryString] autorelease]];
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
    
    self.mapView.delegate = self;
    
    MKCoordinateRegion region;
    CLLocation *location = self.place.location;
    
    region.center = location.coordinate;  
    
    MKCoordinateSpan span; 
    
    span.latitudeDelta  = 0.02; // default zoom
    
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
    
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
