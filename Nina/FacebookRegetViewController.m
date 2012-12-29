//
//  FacebookRegetViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-07-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookRegetViewController.h"

#import "NinaAppDelegate.h"
#import "UserManager.h"

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
    [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:TRUE completionHandler:^(FBSession *session,
                                                                                                                                                                                                          FBSessionState state, NSError *error) {
            User *user = [UserManager sharedMeUser];
            [NinaHelper updateFacebookCredentials:session forUser:user];
    }];
}

-(IBAction) logout{
    [NinaHelper clearCredentials];
    [self close];
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



@end

