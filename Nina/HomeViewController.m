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
#import "FriendFindController.h"
#import "NearbySuggestedMapController.h"
#import "EditProfileViewController.h"
#import "UserManager.h"
#import "QuestionListViewController.h"



@interface HomeViewController (Private) 
- (IBAction) buttonTouchUpInside:(id)sender;
@end


@implementation HomeViewController
@synthesize pickScroll, scrollFooter, placemarkButton;
@synthesize mapLabel, feedLabel, profileLabel, peopleLabel;

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSArray *pickCategories = [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:@"FoodPick.png", @"image", @"Restaurants & Food", @"category",  @"Food", @"title", nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"ShoppingPick.png", @"image", @"Shopping", @"category",  @"Shopping", @"title", nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"TouristyPick.png", @"image", @"Interesting & Outdoors", @"category",  @"Interesting", @"title", nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"NightlifePick.png", @"image", @"Bars & Nightlife", @"category",  @"Nightlife", @"title", nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:@"GasPick.png", @"image", @"Gas Station", @"category",  @"Gas", @"title", nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"BeautyPick.png", @"image", @"Beauty", @"category",  @"Beauty", @"title", nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"GovernmentPick.png", @"image", @"Government", @"category",  @"Government", @"title", nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"EverythingPick.png", @"image", @"", @"category",  @"Everything", @"title", nil],
                               nil];

    CGFloat cx = 5;
        
    for( NSDictionary *quickPick in pickCategories ){

        CGRect rect = CGRectMake(cx, 3, 60, 60);
        QuickPickButton *button = [[QuickPickButton alloc] initWithFrame:rect];
        button.category = [quickPick objectForKey:@"category"];
        UIImage *image = [UIImage imageNamed:[quickPick objectForKey:@"image"]];
        UIImage *activeImage = [UIImage imageNamed:[NSString stringWithFormat:@"Active%@",[quickPick objectForKey:@"image"]] ];
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:activeImage forState:UIControlStateHighlighted];
        [button.titleLabel setText:[quickPick objectForKey:@"title"]];
        [self.pickScroll addSubview:button];
        
        [button addTarget:self action:@selector(showQuickPick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button release];
        
        CGRect labelRect = CGRectMake(cx, 64, 64, 30);
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        [label setFont:[UIFont fontWithName:@"Arial" size:11]];
        
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        
        label.text = [quickPick objectForKey:@"title"];
        [self.pickScroll addSubview:label];
        [label release];
        
        cx += button.frame.size.width+5;

    }
    
    [self.pickScroll setContentSize:CGSizeMake(cx, [self.pickScroll bounds].size.height)];
    
    [self.scrollFooter setFrame:CGRectMake(self.scrollFooter.frame.origin.x, self.scrollFooter.frame.origin.y, MAX(cx, 320), self.scrollFooter.frame.size.height)];
    
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_script.png"]] autorelease];
    self.navigationItem.title = @"Placeling";
    
    UITapGestureRecognizer *navSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutUs)];
    navSingleTap.numberOfTapsRequired = 1;
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] addGestureRecognizer:navSingleTap];
    [navSingleTap release];
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = manager.location;
    
	if (location != nil){ 
        
        [FlurryAnalytics setLatitude:location.coordinate.latitude            
                           longitude:location.coordinate.longitude           
                    horizontalAccuracy:location.horizontalAccuracy            verticalAccuracy:location.verticalAccuracy]; 
    }

    [FlurryAnalytics setUserID:[[UIDevice currentDevice]uniqueDeviceIdentifier] ];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (customBadge){
        [customBadge removeFromSuperview];
        customBadge = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshNotificationBadge];
}

-(void)refreshNotificationBadge{
    User *user = [UserManager sharedMeUserNoGrab];
    
    if (user && user.notificationCount && [user.notificationCount intValue] > 0){
        if (customBadge){
            [customBadge removeFromSuperview];
            customBadge = nil;
        }
        
        customBadge = [CustomBadge customBadgeWithString:[user.notificationCount stringValue]
                                         withStringColor:[UIColor whiteColor]
                                          withInsetColor:[UIColor redColor]
                                          withBadgeFrame:YES
                                     withBadgeFrameColor:[UIColor whiteColor]
                                               withScale:1.0
                                             withShining:YES];
            [customBadge setFrame:CGRectMake(265, 20, customBadge.frame.size.width, customBadge.frame.size.height)];
        [customBadge setUserInteractionEnabled:NO];
        [self.navigationController.view addSubview:customBadge];
        
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:TRUE];    
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleBackgroundView:self.view];
    
    [StyleHelper styleHomePageLabel:self.mapLabel];
    [StyleHelper styleHomePageLabel:self.feedLabel];
    [StyleHelper styleHomePageLabel:self.profileLabel];
    [StyleHelper styleHomePageLabel:self.peopleLabel];    
    
    
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
    self.pickScroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pickBackground.png"]];
    [placemarkButton setImage:[UIImage imageNamed:@"PlaceMarkIt_Pressed.png"] forState:UIControlStateHighlighted];

    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"08-chat.png"] style:UIBarButtonItemStylePlain target:self action:@selector(activityFeed:) ];
    self.navigationItem.rightBarButtonItem = modalButton;
    [modalButton release];
}

- (IBAction) showQuickPick:(id)sender {
    QuickPickButton *buttonClicked = (QuickPickButton *)sender;
    
    NearbySuggestedPlaceController *nearbyPlaceController = [[NearbySuggestedPlaceController alloc] init];    
    
    nearbyPlaceController.category = buttonClicked.category;
    nearbyPlaceController.quickpick = true;
    if ( [buttonClicked.titleLabel.text isEqualToString:@"Gas"] ){
        //special case where we initialize to popular since few people will bookmark gas stations
        nearbyPlaceController.initialIndex = 2;
    }
    
    nearbyPlaceController.navTitle = buttonClicked.titleLabel.text;
    
    [self.navigationController pushViewController:nearbyPlaceController animated:TRUE];
    [nearbyPlaceController release];
}

-(IBAction)showLogin{
    LoginController *loginController = [[LoginController alloc] init];
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
    [FlurryAnalytics logAllPageViews:navBar];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:@"Edit My Profile",nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self logout];
    } else if (buttonIndex == 1){
        
        EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] init];
        editProfileViewController.user = [UserManager sharedMeUser];
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:editProfileViewController];
        [StyleHelper styleNavigationBar:navBar.navigationBar];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        
        [editProfileViewController release]; 
        
        
    }else {
        DLog(@"WARNING - Invalid actionsheet button pressed: %i", buttonIndex);
    }
    
}


#pragma mark -IBActions

-(IBAction) questions{
    QuestionListViewController *questionList = [[QuestionListViewController alloc] init];
    [self.navigationController pushViewController:questionList animated:YES];
    [questionList release];
}

-(IBAction) everythingList{
    NearbySuggestedPlaceController *nearbySuggestedPlaceController = [[NearbySuggestedPlaceController alloc] init];
    [self.navigationController pushViewController:nearbySuggestedPlaceController animated:YES];
    [nearbySuggestedPlaceController release]; 
}

-(IBAction)nearbyPerspectives{
    NearbySuggestedMapController *nearbySuggestedMapController = [[NearbySuggestedMapController alloc] init];    
    nearbySuggestedMapController.category = @"";
    nearbySuggestedMapController.navTitle = @"My Map";
    nearbySuggestedMapController.initialIndex = 1; //start on following
    [self.navigationController pushViewController:nearbySuggestedMapController animated:TRUE];
    [nearbySuggestedMapController release];
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

-(IBAction) activityFeed:(id)sender{
    ActivityFeedViewController *activityFeedViewController = [[ActivityFeedViewController alloc] init];
    
    if ( [sender class] == [UIBarButtonItem class] ){
        activityFeedViewController.initialIndex = 0;
    } else {
        activityFeedViewController.initialIndex = 1;
    }
    [self.navigationController pushViewController:activityFeedViewController animated:true];
    
    [activityFeedViewController release];
}

-(void)aboutUs {
    AboutUsController *about = [[AboutUsController alloc] initWithNibName:@"AboutUsController" bundle:nil];
	[self.navigationController pushViewController:about animated:TRUE];
	[about release];
}


-(IBAction) findFriends{    
    FriendFindController *friendFindController = [[FriendFindController alloc] init];
    [self.navigationController pushViewController:friendFindController animated:YES];
    [friendFindController release]; 
}


-(IBAction) logout{
    [NinaHelper clearCredentials];
    
    [self viewWillAppear:NO];
    
}

-(void) dealloc{
    [pickScroll release];
    [mapLabel release];
    [feedLabel release];
    [profileLabel release];
    [peopleLabel release];
    [scrollFooter release];
    [placemarkButton release];
    [super dealloc];
}



@end
