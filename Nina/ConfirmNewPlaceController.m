//
//  ConfirmNewPlaceController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfirmNewPlaceController.h"
#import "UIImageView+WebCache.h"
#import "Place.h"
#import "PlacePageViewController.h"

@implementation ConfirmNewPlaceController

@synthesize categories, addressComponents, location, placeName, selectedCategory;

@synthesize placeNameLabel, categoryLabel, address, city, mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.placeNameLabel.text = self.placeName;
    self.categoryLabel.text = self.selectedCategory;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    NSString* lat = [NSString stringWithFormat:@"%f",self.location.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f",self.location.longitude];    
    
    NSString* imageMapWidth = [NSString stringWithFormat:@"%i", (int)self.mapView.frame.size.width ];
    NSString* imageMapHeight = [NSString stringWithFormat:@"%i", (int)self.mapView.frame.size.height ];
    
    NSString *mapURL;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=%@x%@&&markers=icon:http://www.placeling.com/images/marker.png%%7Ccolor:red%%7C%@,%@&sensor=false&scale=2", lat, lng, imageMapWidth, imageMapHeight, lat, lng];
    } else {
        mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=%@x%@&&markers=icon:http://www.placeling.com/images/marker.png%%7Ccolor:red%%7C%@,%@&sensor=false", lat, lng, imageMapWidth, imageMapHeight, lat, lng];
    }
    
    NSURL *url = [NSURL URLWithString:mapURL];
    [self.mapView setImageWithURL:url];
    
    
    
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Create Place" style:UIBarButtonItemStylePlain target:self action:@selector(confirmPlace)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    NSString *number = @"";
    NSString *street = @"";
    NSString *cityName = @"";
    NSString *province = @"";
    
    for (NSDictionary* adComponent in self.addressComponents){
        if ([[adComponent objectForKey:@"types"] containsObject:@"locality"]){
            cityName = [adComponent objectForKey:@"long_name"]; 
        } else if ([[adComponent objectForKey:@"types"] containsObject:@"route"]){
            street = [adComponent objectForKey:@"long_name"]; 
        } else if ([[adComponent objectForKey:@"types"] containsObject:@"administrative_area_level_1"]){
            province = [adComponent objectForKey:@"short_name"]; 
        } else if ([[adComponent objectForKey:@"types"] containsObject:@"street_number"]){
            number = [adComponent objectForKey:@"long_name"]; 
        }
    }
    
    if ( number || street ){
        self.address.text = [NSString stringWithFormat:@"%@ %@", number, street];
    }
    
    if ( cityName || province ){
        self.city.text = [NSString stringWithFormat:@"%@, %@", cityName, province]; 
    }
    
}

// Dismiss keyboard if tap outside text field and not on button/reset password link
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( [touch.view isKindOfClass:[UITextField class]] ){
        return NO;
    } 
    return YES;
}

-(void)dismissKeyboard:(id)sender {
    [self.address resignFirstResponder];
    [self.city resignFirstResponder];
}


-(void) confirmPlace{
    [self dismissKeyboard:nil];
    
    NSArray *categoryComponents = [self.selectedCategory componentsSeparatedByString:@" - "];
    
    NSDictionary *cat = self.categories;
    NSString *categoryString;
    for (NSString* component in categoryComponents){
        if ( [[cat objectForKey:component] isKindOfClass:[NSDictionary class]] ){
            cat = [cat objectForKey:component];
        } else {
            categoryString = [cat objectForKey:component];
        }
    }
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/v1/places" usingBlock:^(RKObjectLoader *loader){
        loader.method = RKRequestMethodPOST;
        RKParams* params = [RKParams params];
        [params setValue:placeName forParam:@"name"];
        [params setValue:self.address.text forParam:@"street_address" ];
        [params setValue:self.city.text forParam:@"city_data" ];
        [params setValue:[NSString stringWithFormat:@"%f", self.location.latitude] forParam:@"place_lat" ];
        [params setValue:[NSString stringWithFormat:@"%f", self.location.longitude] forParam:@"place_lng" ];
        [params setValue:categoryString forParam:@"initial_venue_type" ];
        loader.params = params;
        loader.delegate = self;
        
    }];

    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
    hud.labelText = @"Saving Place...";
    [hud retain];
}

- (void)hudWasHidden{
    [hud release];
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [hud hide:TRUE];
    
    Place *place = [objects objectAtIndex:0];
    
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
    [self.navigationController pushViewController:placePageViewController animated:true];
    
    NSArray * viewControllers = [self.navigationController viewControllers];
    NSArray * newViewControllers = [NSArray arrayWithObjects:[viewControllers objectAtIndex:0],placePageViewController,nil];
    [self.navigationController setViewControllers:newViewControllers];
    
    [placePageViewController release];

}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [hud hide:TRUE];
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.view];
    self.navigationItem.title = @"Confirm";
    
    self.mapView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.mapView.layer.borderWidth = 3.0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc{
    [categories release];
    [addressComponents release];
    [placeName release];
    [selectedCategory release];
    
    [placeNameLabel release];
    [categoryLabel release];
    [address release];
    [city release];
    [mapView release];
    
    [super dealloc];
}

@end
