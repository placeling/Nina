//
//  FollowViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FollowViewController.h"
#import "User.h"
#import "NSString+SBJSON.h"
#import "MemberProfileViewController.h"
#import "UIImageView+WebCache.h"

@implementation FollowViewController

@synthesize user=_user;
@synthesize place=_place;
@synthesize users, following;

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithUser:(User*)focusUser andFollowing:(bool)follow{
    self = [super init];
    if (self) {
        self.following = follow;
        self.user = focusUser;
    }
    return self;
}

-(id) initWithPlace:(Place*)place andFollowing:(bool)follow{
    self = [super init];
    if (self) {
        self.place = place;
        self.following = follow;
    }
    return self;
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    users = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (User* user in objects){
        [users addObject:user];
    }
    
    [self.tableView reloadData]; 
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    NSString *targetURL;
    
    if (self.place){        
        self.navigationItem.title = self.place.name;  
        
        if (self.following){
            targetURL = [NSString stringWithFormat:@"/v1/places/%@/users?filter_follow=true", self.place.place_id];
        } else {
            targetURL = [NSString stringWithFormat:@"/v1/places/%@/users", self.place.place_id];
        }        
    } else {
        if (self.following){
            targetURL = [NSString stringWithFormat:@"/v1/users/%@/following", self.user.username];
            self.navigationItem.title = @"Following";
        } else {
            targetURL = [NSString stringWithFormat:@"/v1/users/%@/followers", self.user.username];
            self.navigationItem.title = @"Followers";
        }
    }
    	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:targetURL delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if (users){
        if ([users count] == 0) {
            return 1;
        } else {
            return [users count];
        }
    } else {
        return 0; //show a loading spinny or something
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ((users) && [users count] == 0) {
        tableView.allowsSelection = NO;
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        if (self.place){
            if (self.following) {
                cell.textLabel.text = @"Nobody you follow has bookmarked this location";
            } else {
                cell.textLabel.text = @"Nobody has bookmarked this location";
            }            
        } else {
            if (self.following) {
                if ([self.user.username isEqualToString:[NinaHelper getUsername]]) {
                    cell.textLabel.text = @"You're not yet following anyone";
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ isn't yet following anyone", self.user.username];
                }
            } else {
                if ([self.user.username isEqualToString:[NinaHelper getUsername]]) {
                    cell.textLabel.text = @"No one's yet following you";
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"No one's yet following %@", self.user.username];
                }
            }
        }
    } else {
        tableView.allowsSelection = YES;
        User* user = [users objectAtIndex:indexPath.row];

        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.userDescription;
        
        cell.accessoryView.tag = indexPath.row;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumbUrl]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.user = [self.users objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release]; 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) dealloc{
    [NinaHelper clearActiveRequests:40];
    [users release];
    [_user release];
    [_place release];
    [super dealloc];
    
}

@end
