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
#import "MemberProfileViewController.h"
#import "SuggestUserViewController.h"
#import "PerspectivesMapViewController.h"
#import "NinaHelper.h"
#import "NSString+SBJSON.h"
#import "Place.h"
#import "PlacePageViewController.h"

#import "MBProgressHUD.h"

@implementation HomeViewController


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIBarButtonItem *accountButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(showAccountSheet)];
    self.navigationItem.leftBarButtonItem = accountButton;
    [accountButton release];
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

-(IBAction)suggested{
    SuggestUserViewController *suggestUserViewController = [[SuggestUserViewController alloc] init];
    [self.navigationController pushViewController:suggestUserViewController animated:YES];
    [suggestUserViewController release]; 
}

-(IBAction)nearbyPerspectives{
    PerspectivesMapViewController *perspectivesMapViewController = [[PerspectivesMapViewController alloc] init];
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
        
        
        [self.navigationController pushViewController:placePageViewController animated:TRUE];
        
        [placePageViewController release];
    }];
    [request setFailedBlock:^{
        //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        NSError *error = [request error];
        DLog(@"%@", error);
    }];
    
    
	
    [request startAsynchronous];

    
}

-(IBAction) logout{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token_secret"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
}





@end
