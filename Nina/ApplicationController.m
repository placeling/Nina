//
//  ApplicationController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "FlurryAnalytics.h"
#import "NinaAppDelegate.h"

@implementation ApplicationController


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)fbDidLogin {
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/auth/facebook/add", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    [request setPostValue:[facebook accessToken] forKey:@"token" ];
    [request setPostValue:[facebook expirationDate] forKey:@"expiry" ];
    
    [NinaHelper signRequest:request];
    
    [request startAsynchronous];//fire and forget
    
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    [FlurryAnalytics logEvent:@"REJECTED_PERMISSIONS"];
} 

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{
    
}

-(void)fbSessionInvalidated{
    
}

-(void)fbDidLogout{
    
}


@end
