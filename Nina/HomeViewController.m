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
#import "NearbySuggestedPlaceController.h"
#import "FlurryAnalytics.h"
#import "MBProgressHUD.h"
#import "UIDevice+IdentifierAddition.h"
#import "ActivityFeedViewController.h"
#import "AboutUsController.h"
#import "QuickPickButton.h"


@interface HomeViewController (Private) 
- (IBAction) buttonTouchUpInside:(id)sender;
@end


@implementation HomeViewController
@synthesize pickScroll, scrollFooter;

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSDictionary *pickCategories = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObjects:@"EverythingPick.png", @"", nil], @"Everything", 
            [NSArray arrayWithObjects:@"NightLifePick.png", @"Bars & Nightlife", nil], @"Nightlife",
            [NSArray arrayWithObjects:@"FoodPick.png", @"Restaurants & Food", nil], @"Restaurants",
            [NSArray arrayWithObjects:@"TouristyPick.png", @"Interesting & Outdoors", nil], @"Touristy", nil];

    CGFloat cx = 10;
    
    NSEnumerator *enumerator = [pickCategories keyEnumerator];
    id key;
        
    while( key = [enumerator nextObject] ){
        NSArray *category = [pickCategories objectForKey:key];

        CGRect rect = CGRectMake(cx, 3, 64, 64);
        QuickPickButton *button = [[QuickPickButton alloc] initWithFrame:rect];
        button.category = [category objectAtIndex:1];
        UIImage *image = [UIImage imageNamed:[category objectAtIndex:0]];
        [button setImage:image forState:UIControlStateNormal];
        [self.pickScroll addSubview:button];
        
        [button addTarget:self action:@selector(showQuickPick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button release];
        
        CGRect labelRect = CGRectMake(cx, 64, 64, 30);
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        [label setFont:[UIFont fontWithName:@"Arial" size:11]];
        
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        
        label.text = key;
        [self.pickScroll addSubview:label];
        [label release];
        
        cx += button.frame.size.width+10;

    }
    
    [self.pickScroll setContentSize:CGSizeMake(cx, [self.pickScroll bounds].size.height)];
    
    [self.scrollFooter setFrame:CGRectMake(self.scrollFooter.frame.origin.x, self.scrollFooter.frame.origin.y, MAX(cx, 320), self.scrollFooter.frame.size.height)];
    
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_script.png"]] autorelease];
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
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleBackgroundView:self.view];
    
    if ([NinaHelper getAccessTokenSecret]){
        UIImage *image = [UIImage imageNamed:@"gear.png"];
        UIBarButtonItem *accountButton =  [[UIBarButtonItem  alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showAccountSheet)];
        self.navigationItem.leftBarButtonItem = accountButton;
        [accountButton release];  
    } else {
        UIImage *image = [UIImage imageNamed:@"key.png"];
        UIBarButtonItem *loginButton =  [[UIBarButtonItem  alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showLogin)];
        self.navigationItem.leftBarButtonItem = loginButton;
        [loginButton release];
    }
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(aboutUs) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    self.pickScroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pickBackground.png"]];
    
    self.navigationItem.rightBarButtonItem = modalButton;
}

- (IBAction) showQuickPick:(id)sender {
    QuickPickButton *buttonClicked = (QuickPickButton *)sender;
    
    NearbySuggestedPlaceController *nearbyPlaceController = [[NearbySuggestedPlaceController alloc] init];    
    
    nearbyPlaceController.category = buttonClicked.category;
    
    [self.navigationController pushViewController:nearbyPlaceController animated:TRUE];
    [nearbyPlaceController release];
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
    NearbySuggestedPlaceController *nearbySuggestedPlaceController = [[NearbySuggestedPlaceController alloc] init];
    [self.navigationController pushViewController:nearbySuggestedPlaceController animated:YES];
    [nearbySuggestedPlaceController release]; 
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

-(IBAction) activityFeed{
    ActivityFeedViewController *activityFeedViewController = [[ActivityFeedViewController alloc] init];
    
    [self.navigationController pushViewController:activityFeedViewController animated:true];
    [activityFeedViewController release];
}

-(void)aboutUs {
    AboutUsController *about = [[AboutUsController alloc] initWithNibName:@"AboutUsController" bundle:nil];
	[self.navigationController pushViewController:about animated:TRUE];
	[about release];
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

-(void) dealloc{
    [pickScroll release];
    [scrollFooter release];
    [super dealloc];
}



@end
