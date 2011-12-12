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

#pragma mark - asi request handlers

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching binary data
	int statusCode = [request responseStatusCode];
	if (200 != statusCode){
        [NinaHelper handleBadRequest:request  sender:self];
	} else {
		NSString *responseString = [request responseString];
        DLog(@"Got JSON BACK: %@", responseString);
        
        [users release];
        NSDictionary *jsonDict = [responseString JSONValue];
        NSMutableArray *rawUsers;
        
        if (self.place){
             rawUsers = [jsonDict objectForKey:@"users"];           
        } else {
            if (self.following){
                rawUsers = [jsonDict objectForKey:@"following"];
            } else {
                rawUsers = [jsonDict objectForKey:@"followers"];
            }
        }
        
        users = [[NSMutableArray alloc] initWithCapacity:[rawUsers count]];
        
        for (NSDictionary* dict in rawUsers){
            User* newUser = [[User alloc] initFromJsonDict:dict];
            [users addObject:newUser]; 
            [newUser release];
        }
        
        [self.tableView reloadData];
	}
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *urlString;
    
    if (self.place){        
        self.navigationItem.title = self.place.name;  
        
        if (self.following){
            urlString = [NSString stringWithFormat:@"%@/v1/places/%@/users?filter_follow=true", [NinaHelper getHostname], self.place.place_id];
        } else {
            urlString = [NSString stringWithFormat:@"%@/v1/places/%@/users", [NinaHelper getHostname], self.place.place_id];
        }
        
    } else {
        if (self.following){
            urlString = [NSString stringWithFormat:@"%@/v1/users/%@/following", [NinaHelper getHostname], self.user.username];
            self.navigationItem.title = @"Following";
        } else {
            urlString = [NSString stringWithFormat:@"%@/v1/users/%@/followers", [NinaHelper getHostname], self.user.username];
            self.navigationItem.title = @"Followers";
        }
    }
    	
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    [request setTag:40];
    [request setDelegate:self];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];

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
        cell.detailTextLabel.text = user.description;
        
        cell.accessoryView.tag = indexPath.row;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumb_url]
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
