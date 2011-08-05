//
//  HomeViewController.m
//  
//
//  Created by Ian MacKinnon on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "UserPerspectiveMapViewController.h"
#import "NearbyPlacesViewController.h"

@implementation HomeViewController


-(IBAction) bookmarkSpot{
    NearbyPlacesViewController *nearbyPlacesViewController = [[NearbyPlacesViewController alloc] init];
    nearbyPlacesViewController.locationManager = manager;
    [self.navigationController pushViewController:nearbyPlacesViewController animated:YES];
    [nearbyPlacesViewController release];
}

-(IBAction) logout{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token_secret"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
}

-(IBAction) perspectives{
    UserPerspectiveMapViewController *userPerspectives = [[UserPerspectiveMapViewController alloc] init];
    [self.navigationController pushViewController:userPerspectives animated:YES];
    [userPerspectives release];
}

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
    
    manager = [[CLLocationManager alloc] init];
    [manager startUpdatingLocation];
    
    
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
