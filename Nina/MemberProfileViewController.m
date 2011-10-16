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
#import <QuartzCore/QuartzCore.h>
#import "FollowViewController.h"
#import "Perspective.h"
#import "PerspectiveTableViewCell.h"
#import "MyPerspectiveCellViewController.h"
#import "PlacePageViewController.h"
#import "PerspectivesMapViewController.h"
#import "ASIDownloadCache.h"
#import "NinaHelper.h"
#import "EditProfileViewController.h"

@interface MemberProfileViewController() 
-(void) blankLoad;
-(void) toggleFollow;
-(IBAction)editUser;
@end


@implementation MemberProfileViewController

@synthesize username;
@synthesize user, profileImageView, headerView;
@synthesize usernameLabel, userDescriptionLabel;
@synthesize followButton, locationLabel;
@synthesize followersButton, followingButton, placeMarkButton;

#pragma mark - View lifecycle

- (void)viewDidLoad{    
    [[NSBundle mainBundle] loadNibNamed:@"ProfileHeaderView" owner:self options:nil];
    
    [super viewDidLoad];
	
    NSString *getUsername;
    if (self.user == nil){
        getUsername = self.username; //if this doesn't work, it better break
    } else if (username == nil)  {
        getUsername = user.username;
        self.username = user.username;
    }
	
    self.tableView.tableHeaderView = self.headerView;
    
    // Call url to get profile details
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/users/%@", [NinaHelper getHostname], getUsername];
    
	NSURL *url = [NSURL URLWithString:urlText];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
	[request setTag:10];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[NinaHelper signRequest:request];
	[request startAsynchronous];
    
	[self blankLoad];
}

-(IBAction)editUser{
    EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editProfileViewController.user = self.user;
    editProfileViewController.delegate = self;
    [self.navigationController pushViewController:editProfileViewController animated:TRUE];
    [editProfileViewController release];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.tableView];
    
    self.profileImageView.layer.cornerRadius = 8.0f;
    self.profileImageView.layer.borderWidth = 1.0f;
    self.profileImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImageView.layer.masksToBounds = YES; 
    
    [StyleHelper styleInfoView:self.headerView];
    
}

-(void) blankLoad{
    UIImage *profileImage = [UIImage imageNamed:@"default_profile_image.png"];
    self.profileImageView.image = profileImage;
    self.usernameLabel.text = @"";
    self.locationLabel.text = @"";
    self.userDescriptionLabel.text = @"";
    
    self.followingButton.detailLabel.text = @"Following";    
    self.followersButton.detailLabel.text = @"Followers";
    self.placeMarkButton.detailLabel.text = @"Bookmarks";
    
    self.followingButton.numberLabel.text = @"-";
    self.followingButton.numberLabel.text = @"-";
    self.followingButton.numberLabel.text = @"-";
    
    self.placeMarkButton.enabled = false;
    self.followButton.enabled = false;
    self.followersButton.enabled = false;
    self.followingButton.enabled = false;
}

-(IBAction) userPerspectives{
    PerspectivesMapViewController *userPerspectives = [[PerspectivesMapViewController alloc] init];
    userPerspectives.username = self.user.username;
    userPerspectives.user = self.user;
    [self.navigationController pushViewController:userPerspectives animated:YES];
    [userPerspectives release];
}

-(IBAction) userFollowers{
    FollowViewController *followViewController = [[FollowViewController alloc] initWithUser:user andFollowing:false];
    [self.navigationController pushViewController:followViewController animated:YES];
    [followViewController release];
}

-(IBAction) userFollowing{
    FollowViewController *followViewController = [[FollowViewController alloc] initWithUser:user andFollowing:true];
    [self.navigationController pushViewController:followViewController animated:YES];
    [followViewController release];
}

-(void) loadData{
    self.usernameLabel.text = self.user.username;
    self.locationLabel.text = self.user.city;
    self.userDescriptionLabel.text = self.user.description;
    
    
    self.followingButton.detailLabel.text = @"Following";    
    self.followersButton.detailLabel.text = @"Followers";
    self.placeMarkButton.detailLabel.text = @"Bookmarks";
    
    self.placeMarkButton.enabled = true;
    self.followersButton.enabled = true;
    self.followingButton.enabled = true;
    
    if (self.user.following){
        [self toggleFollow];
    } else {
        self.followButton.enabled = true;
    }
    
    self.followingButton.numberLabel.text = [NSString stringWithFormat:@"%i", self.user.followingCount];
    self.followersButton.numberLabel.text = [NSString stringWithFormat:@"%i", self.user.followerCount];
    self.placeMarkButton.numberLabel.text = [NSString stringWithFormat:@"%i", self.user.placeCount];
    
    if (perspectives == nil && self.user.placeCount != 0){
        NSString *urlString = [NSString stringWithFormat:@"%@/v1/users/%@/", [NinaHelper getHostname], self.username];		
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        
        [request setDelegate:self];
        [request setTag:13];
        [NinaHelper signRequest:request];
        [request startAsynchronous];
        
    } else {
        [self.tableView reloadData];
    }
    
    if ([self.username isEqualToString:[NinaHelper getUsername]]){
        UIBarButtonItem *editButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editUser)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
    }
    
    self.profileImageView.photo = self.user.profilePic;
    [self.profileImageView loadImage];
    
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
    [request setTag:11];
    [NinaHelper signRequest:request];
	[request startAsynchronous];
	
}

#pragma mark -
#pragma mark ASIHTTPRequest Delegate Methods

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (request.responseStatusCode != 200){
        [NinaHelper handleBadRequest:request sender:self];
        return;
    }
    
    switch (request.tag){
        case 10:
        {    
            NSString *responseString = [request responseString];            
            DLog(@"profile get returned: %@", responseString);
            
            // Place an asynchronous request to get the profile image
            /*
             NSString *picURL = [NSString stringWithFormat:@"%@", [self.targetProfile objectForKey:@"pho"]];
             NSURL *targetURL = [NSURL URLWithString:picURL];
             ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:targetURL];
             
             */
            
            NSDictionary *jsonDict =  [responseString JSONValue];
            
            self.user = [[[User alloc] initFromJsonDict:jsonDict]autorelease];    
            
            if (self.user.following || [self.username isEqualToString:[NinaHelper getUsername]] ){
                [self toggleFollow];
            }
            
            if ([jsonDict objectForKey:@"perspectives"]){
                //has perspectives in call, seed with to make quicker
                NSMutableArray *rawPerspectives = [jsonDict objectForKey:@"perspectives"];                
                perspectives = [[NSMutableArray alloc] initWithCapacity:[rawPerspectives count]];
                
                for (NSDictionary* dict in rawPerspectives){
                    Perspective* newPerspective = [[Perspective alloc] initFromJsonDict:dict];
                    newPerspective.user = self.user;
                    [perspectives addObject:newPerspective]; 
                    [newPerspective release];
                }
            }
            
            [self loadData];
            break;
        }
        case 11:
        {
            [self toggleFollow];
            break;
        }
            
        case 12:
        {
            DLog(@"Image request finished");
            // Get data and convert to image
            NSData *responseData = [request responseData];
            UIImage *newImage = [UIImage imageWithData:responseData];
            
            self.profileImageView.image = newImage;
        }
        case 13:
        {
            NSData *data = [request responseData];
            
            // Store incoming data into a string
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DLog(@"Got JSON BACK: %@", jsonString);
            // Create a dictionary from the JSON string

            NSMutableArray *rawPerspectives = [[jsonString JSONValue] objectForKey:@"perspectives"];
            perspectives = [[NSMutableArray alloc] initWithCapacity:[rawPerspectives count]];
            
            for (NSDictionary* dict in rawPerspectives){
                Perspective* newPerspective = [[Perspective alloc] initFromJsonDict:dict];
                newPerspective.user = self.user;
                [perspectives addObject:newPerspective]; 
                [newPerspective release];
            }
            
            [jsonString release];
            [self.tableView reloadData];
            
        }
    }

}

-(void) toggleFollow{
    self.followButton.enabled = FALSE;
    self.followButton.titleLabel.textColor = [UIColor grayColor];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    //a visible perspective row PerspectiveTableViewCell
    
    Perspective *perspective;

    perspective = [perspectives objectAtIndex:indexPath.row];
    
    return [PerspectiveTableViewCell cellHeightForPerspective:perspective];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (perspectives){
        return [perspectives count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *perspectiveCellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:perspectiveCellIdentifier];
    
    if (cell == nil) {
        Perspective *perspective = [perspectives objectAtIndex:indexPath.row];

        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PerspectiveTableViewCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                PerspectiveTableViewCell *pcell = (PerspectiveTableViewCell *)item;                  
                [PerspectiveTableViewCell setupCell:pcell forPerspective:perspective userSource:true];
                cell = pcell;
                break;
            }
        }            
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:perspective.place];
    placePageViewController.referrer = self.user;
    
	[[self navigationController] pushViewController:placePageViewController animated:YES];
	[placePageViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




- (void)dealloc{
    [NinaHelper clearActiveRequests:10];
    
    [username release];
    [user release];
    
    [locationLabel release];
    [profileImageView release];
    [usernameLabel release];
    [userDescriptionLabel release];
    [followButton release];
    
    [super dealloc];
}

@end
