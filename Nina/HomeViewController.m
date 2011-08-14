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
#import "NinaHelper.h"

@implementation HomeViewController


-(IBAction)suggested{
    SuggestUserViewController *suggestUserViewController = [[SuggestUserViewController alloc] init];
    [self.navigationController pushViewController:suggestUserViewController animated:YES];
    [suggestUserViewController release]; 
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

-(IBAction) logout{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token_secret"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
}



#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
