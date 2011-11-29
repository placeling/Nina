//
//  FriendFindController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-11-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendFindController.h"
#import "User.h"
#import "MemberProfileViewController.h"
#import "JSON.h"


@implementation FriendFindController
@synthesize searchUsers, suggestedUsers, members;
@synthesize searchBar=_searchBar, tableView=_tableView;


-(void) dealloc {
    [searchUsers release];
    [suggestedUsers release];
    [NinaHelper clearActiveRequests:100];
    [_searchBar release];
    [_tableView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Set up buttons
    self.navigationItem.title = @"Find Friends";
    self.searchBar.delegate = self;
    self.suggestedUsers = [[NSMutableArray alloc]init];
    self.searchUsers = [[NSMutableArray alloc]init];
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocationCoordinate2D location = [manager location].coordinate;
	
	NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/suggested?lat=%f&lng=%f", [NinaHelper getHostname], location.latitude, location.longitude];
    
    NSURL *url = [NSURL URLWithString:targetURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    [request setTag:100];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [StyleHelper styleSearchBar:self.searchBar];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/search?q=%@", [NinaHelper getHostname], searchBar.text];
    
    NSURL *url = [NSURL URLWithString:targetURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    [request setTag:101];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [searchBar resignFirstResponder];
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchText length] >= 3){
        NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/search?q=%@", [NinaHelper getHostname], searchText];
        
        NSURL *url = [NSURL URLWithString:targetURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [NinaHelper signRequest:request];
        [request setTag:101];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.members = self.suggestedUsers;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:TRUE animated:true];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:FALSE animated:true];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
	[NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        switch( [request tag] ){
            case 100:{                
                NSString *responseString = [request responseString];
                DLog(@"%@", responseString);

                NSArray *rawUsers = [[responseString JSONValue] objectForKey:@"suggested"];
                [self.suggestedUsers removeAllObjects];
                for (NSDictionary* rawUser in rawUsers){
                    User *user = [[User alloc] initFromJsonDict:rawUser];
                    [self.suggestedUsers addObject:user];
                    [user release];
                }
                self.members = self.suggestedUsers;
                [self.tableView reloadData];                
                break;
            }
            case 101:{
                NSString *responseString = [request responseString];
                DLog(@"%@", responseString);
                
                NSArray *rawUsers = [[responseString JSONValue] objectForKey:@"users"];
                [self.searchUsers removeAllObjects];
                
                for (NSDictionary* rawUser in rawUsers){
                    User *user = [[User alloc] initFromJsonDict:rawUser];
                    [self.searchUsers addObject:user];
                    [user release];
                }
                
                self.members = self.searchUsers;
                [self.tableView reloadData];                
                break;
            }
        }
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Number of rows on screen
    return MAX([self.members count], 1); //in "1" case we have a memo
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
    if (self.members == self.suggestedUsers){
        return @"Top Locals";
    } else {
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *InfoCellIdentifier = @"InfoCell";
    
    UITableViewCell *cell;
    
    if (indexPath.row ==0 && [self.members count] ==0){
        
        cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InfoCellIdentifier] autorelease];
        }
        
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"No Username Matches";
        [cell setUserInteractionEnabled:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {    
        User *user = [self.members objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.description;
        
        cell.accessoryView.tag = indexPath.row;
        
        cell.imageView.image = [UIImage imageNamed:@"default_profile_image.png"];
        
        AsyncImageView *aImageView = [[AsyncImageView alloc] initWithPhoto:user.profilePic];
        aImageView.frame = cell.imageView.frame;
        aImageView.populate = cell.imageView;
        [aImageView loadImage];
        [cell addSubview:aImageView]; //mostly to handle de-allocation
        [aImageView release];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *user = [self.members objectAtIndex:indexPath.row];
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.user = user;
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
