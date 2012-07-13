//
//  FacebookRegetViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-07-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookRegetViewController.h"

#import "NinaHelper.h"
#import "Facebook.h"
#import "NinaAppDelegate.h"
#import "FlurryAnalytics.h"

@interface FacebookRegetViewController ()

@end

@implementation FacebookRegetViewController


-(void) viewDidLoad{
    [super viewDidLoad];
    
    UIBarButtonItem *button =  [[UIBarButtonItem  alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
}

-(IBAction) signupFacebook{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;

    NSArray* permissions =  [[NSArray arrayWithObjects:
                              @"email", @"publish_stream",@"offline_access", nil] retain];
    
    facebook.sessionDelegate = self;
    [facebook authorize:permissions];
    
    [permissions release];            

}

-(void) fbDidLogin{
    [super fbDidLogin];
    [self close];
}


-(IBAction) logout{
    [NinaHelper clearCredentials];
    [self close];
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    [super fbDidNotLogin:cancelled];
    [self logout];
} 
   

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)close{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
}



-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{
    
}

-(void)fbSessionInvalidated{
    
}

-(void)fbDidLogout{
    
}



@end

