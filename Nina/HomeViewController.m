//
//  HomeViewController.m
//  
//
//  Created by Ian MacKinnon on 11-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "NearbyPlacesViewController.h"
#import "MemberProfileViewController.h"
#import "SuggestUserViewController.h"
#import "PerspectivesMapViewController.h"
#import "NinaHelper.h"
#import "NSString+SBJSON.h"
#import "Place.h"
#import "PlacePageViewController.h"
#import "LoginController.h"
#import "PlacesListView.h"
#import "FlurryAnalytics.h"
#import "MBProgressHUD.h"
#import "UIDevice+IdentifierAddition.h"

@implementation HomeViewController


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Placeling";
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = manager.location;
    
	if (location != nil){ 
        
        [FlurryAnalytics setLatitude:location.coordinate.latitude            
                           longitude:location.coordinate.longitude           
                    horizontalAccuracy:location.horizontalAccuracy            verticalAccuracy:location.verticalAccuracy]; 
    }

    [FlurryAnalytics setUserID:[[UIDevice currentDevice]uniqueDeviceIdentifier] ];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:TRUE];
    
    if ([NinaHelper getAccessTokenSecret]){
        UIBarButtonItem *accountButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(showAccountSheet)];
        self.navigationItem.leftBarButtonItem = accountButton;
        [accountButton release];  
    } else {
        UIBarButtonItem *loginButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(showLogin)];
        self.navigationItem.leftBarButtonItem = loginButton;
        [loginButton release];
    } 
}

-(IBAction)showLogin{
    LoginController *loginController = [[LoginController alloc] init];
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [loginController release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -ActionSheet 

-(IBAction)showAccountSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self logout];
    } else {
        DLog(@"WARNING - Invalid actionsheet button pressed: %i", buttonIndex);
    }
    
}


#pragma mark -IBActions

-(IBAction) everythingList{
    PerspectivesMapViewController *userPerspectives = [[PerspectivesMapViewController alloc] init];
    [self.navigationController pushViewController:userPerspectives animated:YES];
    [userPerspectives release];
    /*
    PlacesListView *placesListView = [[PlacesListView alloc] init];
    
    [self.navigationController pushViewController:placesListView animated:YES];
    [placesListView release]; */
}

-(IBAction)suggested{
    SuggestUserViewController *suggestUserViewController = [[SuggestUserViewController alloc] init];
    [self.navigationController pushViewController:suggestUserViewController animated:YES];
    [suggestUserViewController release]; 
}

-(IBAction)nearbyPerspectives{
    PerspectivesMapViewController *perspectivesMapViewController = [[PerspectivesMapViewController alloc] initForUserName:[NinaHelper getUsername]];
    [self.navigationController pushViewController:perspectivesMapViewController animated:YES];
    [perspectivesMapViewController release]; 
}

-(IBAction)myProfile{
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_username"];
    
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release]; 
}

-(IBAction) bookmarkSpot{
    NearbyPlacesViewController *nearbyPlacesViewController = [[NearbyPlacesViewController alloc] init];
    [self.navigationController pushViewController:nearbyPlacesViewController animated:YES];
    [nearbyPlacesViewController release];
}

-(IBAction) random{
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    //hud.labelText = @"Loading";
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = manager.location;
    
    NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/random?lat=%@&long=%@", [NinaHelper getHostname], lat, lon];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    
    [NinaHelper signRequest:request];
    
    [request setCompletionBlock:^{
        //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        NSString *responseString = [request responseString];        
        DLog(@"%@", responseString);
        
        NSDictionary *json_place = [responseString JSONValue];  
        
        Place *place = [[Place alloc] initFromJsonDict:json_place];
        
        PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:place];
        
        [place release];
        [self.navigationController pushViewController:placePageViewController animated:TRUE];
        
        [placePageViewController release];
    }];
    [request setFailedBlock:^{
        //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [NinaHelper handleBadRequest:request sender:self];
    }];
    
    [request startAsynchronous];

    
}

-(IBAction) logout{
    [NinaHelper clearCredentials];
    
    [self viewWillAppear:NO];
    
}





@end
