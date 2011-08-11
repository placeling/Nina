//
//  MemberProfileViewController.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-16.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "MemberProfileViewController.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "NinaHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "FollowViewController.h"
#import "MapController.h"

@implementation MemberProfileViewController

@synthesize username;
@synthesize user;

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [username release];
    [user release];
    [super dealloc];
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

	self.navigationItem.title = self.username;
	
    // Background image
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    
	// Add a "home" button in upper right
	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Home"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(goHome)];
	self.navigationItem.rightBarButtonItem = homeButton;
	[homeButton release];

	
	// Hide navToolbar if showing e.g., coming from looking at details of a user's location
	[self.navigationController setToolbarHidden: YES animated: YES];
	
	// Call url to get profile details
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/users/%@", [NinaHelper getHostname], self.username];
    
	NSURL *url = [NSURL URLWithString:urlText];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[NinaHelper signRequest:request];
	[request startSynchronous];
    
	NSError *error = [request error];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if (error) {
		[NinaHelper handleBadRequest:request sender:self];			
	}else {
		NSString *responseString = [request responseString];
		
		self.user = [[User alloc] initFromJsonDict: [responseString JSONValue]];
                    
        // Set up the TableView Header
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 203)];
        
        // User name
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 51, 190, 28)];
        usernameLabel.text = self.user.username;
        usernameLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
        [containerView addSubview:usernameLabel];
        [usernameLabel release];
        
        
        // ProfilePic
        CGRect myImageRect = CGRectMake(22, 22, 80, 80);
        UIImage *profileImage = [UIImage imageNamed:@"default_image.png"];
        
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:myImageRect];

        profileImageView.image = profileImage;
        profileImageView.tag = 100;
        
        [[profileImageView layer] setCornerRadius:6.0f];
        [[profileImageView layer] setMasksToBounds:YES];
        [[profileImageView layer] setBorderWidth:1.0f];
        [[profileImageView layer] setBorderColor: [UIColor lightGrayColor].CGColor];

        [containerView addSubview:profileImageView];
        [profileImageView release];
        
        // Place an asynchronous request to get the profile image
        /*
        NSString *picURL = [NSString stringWithFormat:@"%@", [self.targetProfile objectForKey:@"pho"]];
        NSURL *targetURL = [NSURL URLWithString:picURL];
        ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:targetURL];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [picRequest setDelegate:self];
        [picRequest startAsynchronous];
        
         */
        // Description
        CGRect frame = profileImageView.frame;
        int height = frame.size.height + frame.origin.y + 5;
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, height, 276, 32)];
        NSString *desc = [NSString stringWithFormat:@"%@", self.user.description];
        descLabel.text = desc;
        [containerView addSubview:descLabel];
        [descLabel release];
        
        // Follow/unfollow Button
        
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        actionButton.frame = CGRectMake(20, 142, 280, 37);
        BOOL following = FALSE;
        if (following == FALSE) {
            [actionButton setTitle:@"Follow" forState:UIControlStateNormal];
        } else {
            [actionButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
        [actionButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[actionButton addTarget:self action:@selector(Test) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:actionButton];
        
        self.tableView.tableHeaderView = containerView;
        [containerView release];
	}
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

	// Show navBar is hidden e.g., coming from confirmation view
	[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Navigation

#pragma mark -
#pragma mark Follow/Unfollow

- (void)buttonClicked:(UIButton *)requestor {
    // Get the URL to call to follow/unfollow
    
	NSString *actionURL = [NSString stringWithFormat:@"%@/v1/users/%@/follow", [NinaHelper getHostname], self.user.username];
	DLog(@"Follow/unfollow url is: %@", actionURL);
	NSURL *url = [NSURL URLWithString:actionURL];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[request startSynchronous];
	NSError *error = [request error];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if (error) {
		[NinaHelper handleBadRequest:request sender:self];
	} else {
		NSString *responseString = [request responseString];
		
		DLog(@"%@", responseString);
		
		NSMutableDictionary *actionResponse = [responseString JSONValue];
		
		NSString *result = [actionResponse objectForKey:@"result"];
		DLog(@"%@", result);

        if ([[requestor currentTitle] isEqualToString:@"Follow"]) {
            [requestor setTitle:@"Unfollow" forState:UIControlStateNormal];
        } else {
            [requestor setTitle:@"Follow" forState:UIControlStateNormal];
        }
        
        // Reload table data to update counts in cells
        [self.tableView reloadData];
	}
     
}

#pragma mark -
#pragma mark ASIHTTPRequest Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    DLog(@"Image request finished");
    // Get data and convert to image
    NSData *responseData = [request responseData];
	UIImage *newImage = [UIImage imageWithData:responseData];
    
    CGRect myImageRect = CGRectMake(22, 22, 80, 80);
    UIImageView *updatedProfileImageView = [[UIImageView alloc] initWithFrame:myImageRect];
    
    updatedProfileImageView.image = newImage;
    updatedProfileImageView.tag = 100;
    
    [[updatedProfileImageView layer] setCornerRadius:6.0f];
    [[updatedProfileImageView layer] setMasksToBounds:YES];
    [[updatedProfileImageView layer] setBorderWidth:1.0f];
    [[updatedProfileImageView layer] setBorderColor: [UIColor lightGrayColor].CGColor];
    
    // Remove the existing image view from the tableHeader
    [[self.tableView.tableHeaderView viewWithTag:100] removeFromSuperview];
    
    [self.tableView.tableHeaderView addSubview:updatedProfileImageView];
    [updatedProfileImageView release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    // Fail silently
	NSError *error = [request error];
	NSLog(@"%@", [error localizedDescription]);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
		return 3;
	}
	// Error case
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // First section: info about user
    if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
			{
				if (self.user.placeCount == 1) {
					cell.textLabel.text = @"1 Place";
				} else {
					cell.textLabel.text = [NSString stringWithFormat:@"%i Places", self.user.placeCount];
				}
				break;
			}
			case 1:
			{
				NSString *followingText = [NSString stringWithFormat:@"%i Following", self.user.followingCount];
				cell.textLabel.text = followingText;
				if ( self.user.followingCount == 0 ) {
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				} else {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}
				
				break;
			}
			case 2:
			{
				if (self.user.followerCount == 1) {
					cell.textLabel.text = @"1 Follower";
				} else {
					cell.textLabel.text = [NSString stringWithFormat:@"%i Followers", self.user.followerCount];
				}
				if (self.user.followingCount == 0) {
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				} else {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}
				
				break;
			}
			default:
				break;
		}		
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
		switch (indexPath.row)
		{
			case 0:
			{
                /*
                MapController *map = [[MapController alloc] initWithNibName:@"MapController" bundle:nil];
                map.mapOwner = self.target;
                map.initialLatitude = [self.targetProfile objectForKey:@"lat"];
                map.initialLongitude = [self.targetProfile objectForKey:@"lng"];
                [self.navigationController pushViewController:map animated:YES];
                [map release];
                */
                break;
			}
			case 1:
			{
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
				if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
					break;
				} else {
					FollowViewController *getFollowing = [[FollowViewController alloc] initWithNibName:@"FollowViewController" bundle:nil];
					getFollowing.listType = @"following";
					getFollowing.username = self.username;
					
					[self.navigationController pushViewController:getFollowing animated:YES];
					
					[getFollowing release];
				}
				break;
			}
			case 2:
			{
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
				if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
					break;
				} else {
					FollowViewController *getFollowers = [[FollowViewController alloc] initWithNibName:@"FollowViewController" bundle:nil];
					getFollowers.listType = @"followers";
					getFollowers.username = self.username;
					
					[self.navigationController pushViewController:getFollowers animated:YES];
					
					[getFollowers release];
				}
				break;
			}
			default:
				NSLog(@"Integer out of range");
				break;
		}	
    }
}

@end
