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


@interface MemberProfileViewController() 
-(void) loadData;
-(void) blankLoad;
-(void) toggleFollow;
@end


@implementation MemberProfileViewController

@synthesize username;
@synthesize user, profileImageView;
@synthesize usernameLabel, userDescriptionLabel;
@synthesize followButton, quadControl;


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
	
	// Call url to get profile details
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/users/%@", [NinaHelper getHostname], self.username];
    
	NSURL *url = [NSURL URLWithString:urlText];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
	[request setTag:0];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[NinaHelper signRequest:request];
	[request startAsynchronous];
    
    self.quadControl.delegate = self;
    
	[self blankLoad];
}

-(void) blankLoad{
    UIImage *profileImage = [UIImage imageNamed:@"default_image.png"];
    self.profileImageView.image = profileImage;
    self.usernameLabel.text = @"";
    self.userDescriptionLabel.text = @"";
    
    
    [self.quadControl setNumber:0
                       caption:@"following"
                        action:@selector(noop)
                   forLocation:TopLeftLocation];
    
    [self.quadControl setNumber:0
                       caption:@"followers"
                        action:@selector(noop)
                   forLocation:TopRightLocation];
    
    [self.quadControl setNumber:0
                       caption:@"bookmarks"
                        action:@selector(noop)
                   forLocation:BottomLeftLocation];
    
    [self.quadControl setNumber:0
                       caption:@"favorites"
                        action:@selector(noop)
                   forLocation:BottomRightLocation];
    
}

-(IBAction) noop{
    
}

-(void) loadData{
    self.usernameLabel.text = self.user.username;
    self.userDescriptionLabel.text = self.user.description;
    
    [self.quadControl setNumber:[NSNumber numberWithInt:self.user.followingCount]
                        caption:@"following"
                         action:@selector(noop)
                    forLocation:TopLeftLocation];
    
    [self.quadControl setNumber:[NSNumber numberWithInt:self.user.followerCount]
                        caption:@"followers"
                         action:@selector(noop)
                    forLocation:TopRightLocation];
    
    [self.quadControl setNumber:[NSNumber numberWithInt:self.user.placeCount]
                        caption:@"bookmarks"
                         action:@selector(noop)
                    forLocation:BottomLeftLocation];
    
    [self.quadControl setNumber:0
                        caption:@""
                         action:@selector(noop)
                    forLocation:BottomRightLocation];
    
    [self.quadControl setNeedsDisplay];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Navigation

#pragma mark -
#pragma mark Follow/Unfollow

-(IBAction) followUser{
    // Get the URL to call to follow/unfollow
    
	NSString *actionURL = [NSString stringWithFormat:@"%@/v1/users/%@/follow", [NinaHelper getHostname], self.user.username];
	DLog(@"Follow/unfollow url is: %@", actionURL);
	NSURL *url = [NSURL URLWithString:actionURL];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[request setDelegate:self];
    [request setTag:1];
	[request startAsynchronous];
	
}

#pragma mark -
#pragma mark ASIHTTPRequest Delegate Methods

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    switch (request.tag){
        case 0:
        {    
            NSString *responseString = [request responseString];            
            DLog(@"profile get returned: %@", responseString);
            
            // Place an asynchronous request to get the profile image
            /*
             NSString *picURL = [NSString stringWithFormat:@"%@", [self.targetProfile objectForKey:@"pho"]];
             NSURL *targetURL = [NSURL URLWithString:picURL];
             ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:targetURL];
             
             */
            
            self.user = [[User alloc] initFromJsonDict: [responseString JSONValue]];    
            [self loadData];
            
            if (self.user.following || [self.user.username isEqualToString:[NinaHelper getUsername]] ){
                [self toggleFollow];
            }
            
            break;
        }
        case 1:
        {
            [self toggleFollow];
            break;
        }
            
        case 2:
        {
            DLog(@"Image request finished");
            // Get data and convert to image
            NSData *responseData = [request responseData];
            UIImage *newImage = [UIImage imageWithData:responseData];
            
            self.profileImageView.image = newImage;
        }
    }

}

-(void) toggleFollow{
    self.followButton.enabled = FALSE;
    self.followButton.titleLabel.text = @"Following";
    self.followButton.titleLabel.textColor = [UIColor grayColor];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
		return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

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
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
            /*
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
             */
            break;
        }
        case 2:
        {
            /*
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
             */
            break;
        }
    }
}

- (void)dealloc{
    [username release];
    [user release];
    
    [profileImageView release];
    [usernameLabel release];
    [userDescriptionLabel release];
    [followButton release];
    [quadControl release];
    
    [super dealloc];
}

@end
