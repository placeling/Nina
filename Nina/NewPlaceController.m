//
//  NewPlaceController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewPlaceController.h"
#import "SBJSON.h"
#import "ConfirmNewPlaceController.h"

@implementation NewPlaceController

@synthesize placeName=_placeName, placeNameField, placeLatLngField, placeCategoryField;
@synthesize mapView, crosshairView, categories, addressComponents;

- (id)initWithName:(NSString *)placeName{
    self = [super init];
    if (self) {
        self.placeName = placeName;
    }
    return self;
}

-(void) dealloc{
    [NinaHelper clearActiveRequests:90];
    [placeNameField release];
    [placeLatLngField release];
    [placeCategoryField release];
    
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.placeNameField.text = self.placeName;
        
    CLLocationManager *locationManager = [LocationManagerManager sharedCLLocationManager];
    //self.mapView.showsUserLocation = false;
    self.mapView.delegate = self;
    
    MKCoordinateRegion region = self.mapView.region;
    
    MKCoordinateSpan span; 
    
    span.latitudeDelta  = 0.01;
    span.longitudeDelta  = 0.01;
    
    region.span = span;
	CLLocation *location = locationManager.location;
    region.center = location.coordinate;  
    
    [self.mapView setRegion:region animated:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(confirmPlace)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];

    NSString *urlString = [NSString stringWithFormat:@"%@/admin/categories.json", [NinaHelper getHostname]];		
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    request.tag = 91;
    [request setDelegate:self];
    
    [request startAsynchronous];

    
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)pickCategoryPopup{
    [self.placeCategoryField resignFirstResponder];
    [self.placeNameField resignFirstResponder];
    
    if ( !self.categories ){
        //hasn't loaded yet, use default categories        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"google_place_mapping" ofType:@"json"];  
        NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];  
        
        self.categories = [fileContent JSONValue];
        [fileContent release];
    }
    CategoryController *categoryController = [[CategoryController alloc] initWithCategory:self.categories];
    categoryController.newPlaceController= self;
    categoryController.delegate = self;
    [self.navigationController pushViewController:categoryController animated:true];
    [categoryController release];
    
    [self.placeCategoryField resignFirstResponder];
    [self.placeNameField resignFirstResponder];
    
}

-(void) updateCategory:(NSString *)category{
    self.placeCategoryField.text = category;
}

-(void)confirmPlace{
    
    
    if ( [self.placeNameField.text length] == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"This place needs a name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        return;
    } 
    
    if ( [self.placeCategoryField.text length] ==0 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"This place needs a category" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    ConfirmNewPlaceController *confirmNewPlaceController = [[ConfirmNewPlaceController alloc] init];
    
    confirmNewPlaceController.addressComponents = self.addressComponents;
    confirmNewPlaceController.location = self.mapView.region.center;
    confirmNewPlaceController.placeName = self.placeNameField.text;
    confirmNewPlaceController.selectedCategory = self.placeCategoryField.text;
    confirmNewPlaceController.categories = self.categories;
    
    [self.navigationController pushViewController:confirmNewPlaceController animated:true];
    
    [confirmNewPlaceController release];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (timer){
        [timer invalidate];
        timer = nil;
    }
    
    MKCoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D center = region.center;
    
    self.placeLatLngField.text = [NSString stringWithFormat:@"%f, %f", center.latitude, center.longitude];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(reverseGeocode)
                                           userInfo:nil
                                            repeats:NO];
}

-(void) reverseGeocode{
    timer = nil;
    
    MKCoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D center = region.center;
    
    NSString* lat = [NSString stringWithFormat:@"%f", center.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", center.longitude];
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=false", lat, lng];		
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    request.tag = 90;
    [request setDelegate:self];
    
    [request startAsynchronous];

}

-(void)requestFinished:(ASIHTTPRequest *)request{
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else { 
        if (request.tag == 90){
            // Store incoming data into a string
            NSString *jsonString = [request responseString];
            DLog(@"Got JSON BACK: %@", jsonString);
            // Create a dictionary from the JSON string
            
            NSDictionary *jsonDict = [jsonString JSONValue];
            
            if (  [[jsonDict objectForKey:@"status"] isEqualToString:@"OK"] ){
                NSArray *results = [jsonDict objectForKey:@"results"];
                if ( [results count] > 0){
                    NSDictionary *result = [results objectAtIndex:0];
                    self.addressComponents = [result objectForKey:@"address_components"];
                }
            }
        } else {
            // Store incoming data into a string
            NSString *jsonString = [request responseString];
            DLog(@"Got JSON BACK: %@", jsonString);
            // Create a dictionary from the JSON string
            
            NSDictionary *jsonDict = [jsonString JSONValue];
            if (!self.categories){ //don't want to overwrite existing
                self.categories = jsonDict;
            }
        }
    }
}

// Dismiss keyboard if tap outside text field and not on button/reset password link
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( touch.view == self.placeNameField ){
        return NO;
    } 
    [self.placeCategoryField resignFirstResponder];
    [self.placeNameField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard:(id)sender {
    [self.placeCategoryField resignFirstResponder];
    [self.placeNameField resignFirstResponder];
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    //[NinaHelper handleBadRequest:request sender:self];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Pick Place";
    [StyleHelper styleBackgroundView:self.view];
    self.mapView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.mapView.layer.borderWidth = 5.0;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
